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

if ! test -f "dbs/food_data.db"; then
    if ! test -d "FoodData_Central_access"; then
        dl_and_dtrx "https://fdc.nal.usda.gov/fdc-datasets/" "FoodData_Central_access_2019-12-17" ".zip"
        bash mdb-export-all/mdb-export-all.sh FoodData_Central_access_2019-12-17/FoodData_Central_access.accdb
    fi
    ls FoodData_Central_access/*csv | xargs printf -- '-f %s ' | xargs csv-to-sqlite -o food_data.db
    mv food_data.db dbs/
fi

if ! test -f "dbs/food_standard_reference.db"; then
    if ! test -d "sr28"; then
        dl_and_dtrx "https://www.ars.usda.gov/ARSUserFiles/80400535/data/SR/sr28/dnload/" "sr28db" ".zip"
        bash mdb-export-all/mdb-export-all.sh sr28db/sr28.accdb
    fi
    ls sr28/*csv | xargs printf -- '-f %s ' | xargs csv-to-sqlite -o food_standard_reference.db
    mv food_standard_reference.db dbs/
fi


if [ $delete_files -eq 1 ]; then
    rm -rf FoodData_Central_access_2019-12-17.zip
    rm -rf FoodData_Central_access
    rm -rf FoodData_Central_access_2019-12-17
    rm -rf sr28db.zip
    rm -rf sr28
    rm -rf sr28db
fi
