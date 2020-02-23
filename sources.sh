# download and extract a zip file if it doesn't exist
function dl_and_dtrx()
{
    if ! test -d "$2"; then
        dtrx $1$2$3
        rm $2$3
    fi
}

function usage
{
        echo "-h: show this menu"
        echo "-k: keep intermediate files"
}

# intermediate files are generated from downloading and extracting
delete_files=1

while getopts "hk" opt; do
    case ${opt} in
    h )
        usage
        ;;
    k )
        echo "Keeping intermediate files"
        delete_files=0
        ;;
    \? )
        usage
        ;;
    esac
done

mkdir -p dbs

# Get main food data
if ! test -f "dbs/food_data.db"; then
    if ! test -d "FoodData_Central_access"; then
        dl_and_dtrx "https://fdc.nal.usda.gov/fdc-datasets/" "FoodData_Central_access_2019-12-17" ".zip"
        # convert the MS Access db into csv files
        bash mdb-export-all/mdb-export-all.sh FoodData_Central_access_2019-12-17/FoodData_Central_access.accdb
    fi

    # collate the csv files into a sqlite database
    ls FoodData_Central_access/*csv | xargs printf -- '-f %s ' | xargs csv-to-sqlite -o food_data.db
    mv food_data.db dbs/
fi

# get reference data
if ! test -f "dbs/food_standard_reference.db"; then
    if ! test -d "sr28"; then
        dl_and_dtrx "https://www.ars.usda.gov/ARSUserFiles/80400535/data/SR/sr28/dnload/" "sr28db" ".zip"
        # convert the MS Access db into csv files
        bash mdb-export-all/mdb-export-all.sh sr28db/sr28.accdb
    fi

    # collate the csv files into a sqlite database
    ls sr28/*csv | xargs printf -- '-f %s ' | xargs csv-to-sqlite -o food_standard_reference.db
    mv food_standard_reference.db dbs/
fi

# delete intermediate files
if [ $delete_files -eq 1 ]; then
    rm -rf FoodData_Central_access_2019-12-17.zip
    rm -rf FoodData_Central_access
    rm -rf FoodData_Central_access_2019-12-17
    rm -rf sr28db.zip
    rm -rf sr28
    rm -rf sr28db
fi
