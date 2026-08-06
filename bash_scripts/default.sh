#!/bin/bash
pwd


# Default case for Linux sed, just use "-i", then expand the parameters in the actual call to "sed"
sedi=(-i)
case "$(uname)" in
  # For macOS, use two parameters
  Darwin*) sedi=(-i "")
esac

# uncomment the model.options.default.txt if it is commented
# remove the // if the line contains model.options.default.txt (only two //)
# sed -i '/FILE_NAME_MODEL_OPTIONS/{/model.options.default.txt/s/^\/\///}' Scripts/config/globalParameters.rgg
sed "${sedi[@]}" -e '/FILE_NAME_MODEL_OPTIONS/{/model.options.default.json/s/^\/\///;}' Scripts/config/globalParameters.rgg
# add comment sign in other scenario files - Note: sed needs to be on separate lines to clarify command nesting for parser
sed "${sedi[@]}" -e '/FILE_NAME_MODEL_OPTIONS/{/model.options.default.json/!{/^[ \t]*\/\//!s/^/\/\//
}
}' Scripts/config/globalParameters.rgg

SCENARIO="model.options.default.json"
# Use sed to replace "shouldContinue": true with "shouldContinue": false for detecting more errors
# sed -i 's/static boolean shouldContinue = true;/static boolean shouldContinue = false;/' Scripts/config/globalParameters.rgg


#SCENARIO=`grep -x -v '//.*' Scripts/globalParameters.rgg | grep -x '.*FILE_NAME_MODEL_OPTIONS.*' | grep -o '".*"' | tr -d '"'`
# string variable
# string variable
species=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'species'| sed 's/.*"\([^"]*\)".*/\1/'| sed 's/\r$//'`
initiation_method=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'initiation_method'| sed 's/.*"\([^"]*\)".*/\1/'| sed 's/\r$//'`
special_scenario=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'special_scenario'| sed 's/.*"\([^"]*\)".*/\1/'| sed 's/\r$//'`
# boolean variable
COMPLEX_BERRY=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'useComplexBerry' | grep -o 'true' | wc -l`
VIRTURAL_FRUIT=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'useVirtualFruit' | grep -o 'true' | wc -l`
COMPLEX_LEAF=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'useComplexLeaf' | grep -o 'true' | wc -l`
COMPLEX_ROOT=`grep -x -v '//.*' Model_scenarios/$SCENARIO | grep 'useComplexRoot' | grep -o 'true' | wc -l`

echo "scenario file is: "$SCENARIO
echo "special_scenario is: "$special_scenario
echo "species is: "$species
echo "COMPLEX_BERRY is: "$COMPLEX_BERRY
echo "VIRTURAL_FRUIT is: "$VIRTURAL_FRUIT

# echo 'Copying updated files from appropriate folders to Extra_modules...'

copy_scripts_to_extra_modules () {
    # Determine the source directory based on the prefix of the argument
    if [[ $1 =~ ^(develop|updates)$ ]]; then
        SOURCE_DIR="Scripts/main"
    elif [[ $1 =~ ^(initiation|simRun|architReconstruction)$ ]]; then
        SOURCE_DIR="Scripts/config"
    elif [[ $1 =~ ^(buds|berry)$ ]]; then
        SOURCE_DIR="Scripts/organs"
    elif [[ $1 =~ ^(soil)$ ]]; then
        SOURCE_DIR="Scripts/environment"
    else
        echo "Unknown module type: $1. Copying from Scripts/"
        SOURCE_DIR="Scripts"
    fi

    # Extract EXTRA_MODULES_FILENAME from the script located in SOURCE_DIR
    FILENAME=`grep -x -v '//.*' ${SOURCE_DIR}/${1}.rgg | grep -x -m 1 '.*EXTRA_MODULES_FILENAME.*' | grep -o '".*"' | tr -d '"'`
    echo "Copying $FILENAME..."

    # Copy and rename the file
    cp "${SOURCE_DIR}/${1}.rgg" "Extra_modules"
    mv "Extra_modules/${1}.rgg" "Extra_modules/$FILENAME"
}

# Test the function with different module types
# copy_scripts_to_extra_modules berry



copy_extra_modules_to_scripts () {

    # @first module name
    # @second module type/scenario name

    FILENAME="$1_$2.rgg"
    echo "Copying $FILENAME..."

    # Determine the target directory based on the prefix of FILENAME
    if [[ $1 =~ ^(buds|berry)$ ]]; then
        TARGET_DIR="Scripts/organs"
    fi

    # Copy the file
    cp "Extra_modules/$FILENAME" "$TARGET_DIR"

    # Rename the file if necessary
    mv "$TARGET_DIR/$FILENAME" "$TARGET_DIR/$1.rgg"
}



