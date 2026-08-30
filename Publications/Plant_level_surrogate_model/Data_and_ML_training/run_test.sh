dirdate=$(date +%Y-%m-%d-%H-%M-%S)

# Test a pretrained regressor model on whole-plant-level prediction tasks
nohup python ML_regression.py --test --task 'light' --model_path 'outputs/2026-08-20-21-16-19_newData_light/MLP_1_model.joblib' --NOW $dirdate >> ./Test_regression-$dirdate.log 2>&1 &
