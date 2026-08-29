dirdate=$(date +%Y-%m-%d-%H-%M-%S)

# Train and test a regressor model on whole-plant-level prediction tasks
#nohup python ML_regression.py --seed 1 --task 'light' --standardize --NOW $dirdate >> ./Train_regression-light-$dirdate.log 2>&1 &
nohup python ML_regression.py --seed 1 --task 'water' --standardize --NOW $dirdate >> ./Train_regression-water-$dirdate.log 2>&1 &

