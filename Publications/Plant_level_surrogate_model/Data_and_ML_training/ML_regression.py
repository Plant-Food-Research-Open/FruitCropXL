from datetime import datetime
import argparse
import os
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeRegressor, ExtraTreeRegressor
from sklearn.ensemble import AdaBoostRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.metrics import r2_score,root_mean_squared_error
from sklearn.multioutput import MultiOutputRegressor
from plot import plot_predicted_actual
import joblib
from load_dataset import TreeDataset0

def ML_regression(ori_data, scaled_data, scalers, name, ML_regressor, args):
    [_, y_train, _, y_test] = ori_data
    [X_train_scaled, y_train_scaled, X_test_scaled, y_test_scaled] = scaled_data
    [scaler1, scaler2] = scalers
    if y_train.ndim == 1:
        model = ML_regressor
    else:
        model = MultiOutputRegressor(ML_regressor)

    model.fit(X_train_scaled, y_train_scaled)
    y_train_pred_scaled = model.predict(X_train_scaled)
    y_test_pred_scaled = model.predict(X_test_scaled)

    if args.scaler_y:
        y_train_pred = scaler2.inverse_transform(y_train_pred_scaled)
        y_test_pred = scaler2.inverse_transform(y_test_pred_scaled)
    else:
        y_train_pred, y_test_pred = y_train_pred_scaled, y_test_pred_scaled

    r2_train = r2_score(y_train, y_train_pred)
    r2_test = r2_score(y_test, y_test_pred)
    r2_test_per_target = r2_score(y_test, y_test_pred, multioutput='raw_values')

    # use train_std to normalise y and calculate the unified rmse, suitable to post-hoc analyis/comparison
    rmse_train_per_target = root_mean_squared_error(y_train, y_train_pred, multioutput='raw_values')
    rmse_test_per_target = root_mean_squared_error(y_test, y_test_pred, multioutput='raw_values')
    std_train_per_target, std_test_per_target = np.std(y_train, axis=0), np.std(y_test, axis=0)
    nrmse_train_per_target = rmse_train_per_target / std_train_per_target
    nrmse_test_per_target = rmse_test_per_target / std_train_per_target
    nrmse_train_unified, nrmse_test_unified = np.mean(nrmse_train_per_target), np.mean(nrmse_test_per_target)

    joblib.dump(model, os.path.join(args.outdir, f'{name}_{args.seed}_model.joblib'))
    if args.plot_results:
        if y_test_pred.ndim == 1:
            plot_predicted_actual(y_test_pred.squeeze(), y_test.squeeze(), os.path.join(args.outdir, '%s_results.pdf'%(name)), args.targets, model=name)
        else:
            for i, target in enumerate(args.targets.split(',')):
                plot_predicted_actual(y_test_pred[:, i], y_test.iloc[:, i], os.path.join(args.outdir, '%s_%s_results.pdf'%(name, target)), target, model=name)
    return nrmse_train_unified, r2_train, nrmse_test_unified, r2_test, r2_test_per_target


def main():
    RMSE = {'AdaBoost':[], 'MLP':[]}
    R2 = {'AdaBoost':[], 'MLP':[]}
    best_set = {'AdaBoost':-1e8, 'MLP':-1e8}
    mean_set = {'AdaBoost':[], 'MLP':[]}
    std_set = {'AdaBoost':[], 'MLP':[]}
    R2_per_target = {'AdaBoost': [], 'MLP': []}

    target_names = args.targets.split(',')

    # seeds = np.arange(30)
    seeds = [args.seed]
    for seed in seeds:
        start_time = datetime.now()
        args.seed = seed
        print('args.seed=', args.seed)
        ori_data = [X_train, y_train, X_test, y_test]
        scaled_data = [X_train_scaled, y_train_scaled, X_test_scaled, y_test_scaled]
        scalers = [scaler1, scaler2]

        # ML_models = {'AdaBoost': AdaBoostRegressor(estimator=ExtraTreeRegressor(max_depth=15, min_samples_split=3), n_estimators=150, learning_rate=2.0, random_state=args.seed),
        #              'MLP': MLPRegressor(hidden_layer_sizes=(256, 128, 64), activation='relu', solver='adam', max_iter=500, random_state=args.seed)}

        ML_models = {'MLP': MLPRegressor(hidden_layer_sizes=(256, 128, 64), activation='relu', solver='adam', max_iter=500, random_state=args.seed)}

        for name, model in ML_models.items():
            rmse_train, r2_train, rmse_test, r2_test, r2_test_per_target = ML_regression(ori_data, scaled_data, scalers, name, model, args)
            print(f'{name} - Mean nRMSE_train: {rmse_train:.4f}, R2_train: {r2_train:.4f}, Mean nRMSE_test: {rmse_test:.4f}, R2_test: {r2_test:.4f}')
            per_target_str = ', '.join(f'{t}: {v:.4f}' for t, v in zip(target_names, r2_test_per_target))
            print(f'  Per-target R2_test (seed {seed}): {per_target_str}')
            RMSE[name].append([rmse_train, rmse_test])
            R2[name].append([r2_train, r2_test])
            R2_per_target[name].append(r2_test_per_target)
            if r2_test > best_set[name]:
                best_set[name] = r2_test
                best_set[name + '_set'] = [rmse_train, r2_train, rmse_test, r2_test, r2_test_per_target]

        end_time = datetime.now()
        print(f'Seed {seed} - Time taken: {end_time - start_time}')

    for name in ML_models.keys():
        mean_rmse_train, mean_rmse_test = np.around(np.mean(RMSE[name], axis=0), 4)
        std_rmse_train, std_rmse_test = np.around(np.std(RMSE[name], axis=0), 4)
        mean_r2_train, mean_r2_test = np.around(np.mean(R2[name], axis=0), 4)
        std_r2_train, std_r2_test = np.around(np.std(R2[name], axis=0), 4)
        mean_r2_per_target = np.around(np.mean(R2_per_target[name], axis=0), 4)
        mean_set[name] = [mean_rmse_train, mean_r2_train, mean_rmse_test, mean_r2_test, *mean_r2_per_target]
        std_set[name] = [std_rmse_train, std_r2_train, std_rmse_test, std_r2_test]

        per_target_str = ', '.join(f'{t}: {v:.4f}' for t, v in zip(target_names, mean_r2_per_target))

        print(f'Avg results over {len(seeds)} seeds for {name}: Mean nRMSE_train: {mean_rmse_train:.4f}-{std_rmse_train:.4f}, R2_train: {mean_r2_train:.4f}-{std_r2_train:.4f}, Mean nRMSE_test: {mean_rmse_test:.4f}-{std_rmse_test:.4f}, R2_test: {mean_r2_test:.4f}-{std_r2_test:.4f}')
        print(f'  Per-target R2_test: {per_target_str}')
        print(f'Best results for {name}: Mean nRMSE_train: {best_set[name + "_set"][0]:.4f}, R2_train: {best_set[name + "_set"][1]:.4f}, Mean nRMSE_test: {best_set[name + "_set"][2]:.4f}, R2_test: {best_set[name + "_set"][3]:.4f}')


    target_names = args.targets.split(',')
    stat = []
    for name in ML_models.keys():
        mean_r2_pt = mean_set[name][4:]
        best_r2_pt = np.around(best_set[name + '_set'][4], 4)
        avg_row = [str(mean_set[name][0]) + '-' + str(std_set[name][0]),
                   str(mean_set[name][1]) + '-' + str(std_set[name][1]),
                   str(mean_set[name][2]) + '-' + str(std_set[name][2]),
                   str(mean_set[name][3]) + '-' + str(std_set[name][3])] + [str(v) for v in mean_r2_pt]
        best_row = [str(best_set[name + '_set'][0]), str(best_set[name + '_set'][1]),
                    str(best_set[name + '_set'][2]), str(best_set[name + '_set'][3])] + [str(v) for v in best_r2_pt]
        stat.extend([avg_row, best_row])

    row_names = [f"{model}_{suffix}" for model in ML_models for suffix in ['avg', 'best']]
    col_names = ['Mean nRMSE_train', 'R2_train', 'Mean nRMSE_test', 'R2_test'] + [f'R2_test_{t}' for t in target_names]

    df1 = pd.DataFrame(stat, index=row_names, columns=col_names)
    df1.to_csv(os.path.join(args.outdir, 'result_%s.csv' % (args.targets)), index=True)


def test_model():
    model = joblib.load(args.model_path)

    y_test_pred_scaled = model.predict(X_test_scaled)
    if args.scaler_y:
        scaler2 = joblib.load(args.scaler2_path)
        y_test_pred = scaler2.inverse_transform(y_test_pred_scaled)
    else:
        y_test_pred = y_test_pred_scaled

    r2_test = r2_score(y_test, y_test_pred)
    r2_test_per_target = r2_score(y_test, y_test_pred, multioutput='raw_values')

    rmse_test_per_target = root_mean_squared_error(y_test, y_test_pred, multioutput='raw_values')
    std_train_per_target = np.std(y_train, axis=0)
    nrmse_test_per_target = rmse_test_per_target / std_train_per_target
    nrmse_test_unified = np.mean(nrmse_test_per_target)

    print(f'Test mean nRMSE: {nrmse_test_unified:.4f}, R2: {r2_test:.4f}')
    print(f'Test nRMSE per target: {nrmse_test_per_target}')
    print(f'R2 per target: {r2_test_per_target}')
    if args.plot_results:
        if y_test_pred.ndim == 1:
            plot_predicted_actual(y_test_pred.squeeze(), y_test.squeeze(), os.path.join(args.outdir, 'test_results.png'), args.targets, model='Loaded Model')
        else:
            for i, target in enumerate(args.targets.split(',')):
                plot_predicted_actual(y_test_pred[:, i], y_test.iloc[:, i], os.path.join(args.outdir, f'test_{target}_results.png'), target, model='Loaded Model')


if __name__ =='__main__':
    NOW = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    parser = argparse.ArgumentParser(description='Node fabs prediction')
    parser.add_argument("--data_loc", type=str, default="./newData", help="batch-waterParameter, dataset-batch-water-default, batch-water-3, batch-direct-light, batch-diffuse-light, batch-total-light, combined_dataset")
    parser.add_argument('--task', default='light', type=str, help='which task, light or water')
    parser.add_argument("--features", type=str, default="", help='type,x,y,z')
    parser.add_argument("--targets", type=str, default="fabsPAR,fPAR_1,waterFlux_optimized,xylemWaterPotential,intWaterPotential_1,intWaterPotential_2,intWaterPotential_3,intWaterPotential_4", help='fabs, waterFlux_optimized, xylemWaterPotential, intWaterPotential_1, intWaterPotential_2, intWaterPotential_3, intWaterPotential_4')
    parser.add_argument('--plot_feature_correlations', default=True, action='store_true')
    parser.add_argument('--plot_results', default=True, action='store_true')
    parser.add_argument("--outdir", type=str, default="outputs")
    parser.add_argument('--standardize', default=True, action='store_true')
    parser.add_argument('--NOW', type=str, default=datetime.now().strftime("%Y-%m-%d-%H-%M-%S"),help='the current date and time')
    parser.add_argument('--model_path', type=str, help='path of the trained model')
    parser.add_argument('--scaler1_path', type=str, help='path of the scaler')
    parser.add_argument('--scaler2_path', type=str, help='path of the scaler2')
    parser.add_argument('--seed', default=1, type=int)
    # parser.add_argument('--trainset_ratio', default=0.8, type=float)
    parser.add_argument('--scaler_y', default=False, action='store_true')
    parser.add_argument('--test', default=False, action='store_true')
    args = parser.parse_args()
    
    if args.task == 'light':
        args.targets = 'fabsPAR,fPAR_1'
    elif args.task == 'water':
        args.targets = 'waterFlux_optimized,xylemWaterPotential,intWaterPotential_1,intWaterPotential_2,intWaterPotential_3,intWaterPotential_4'
    else:
        raise ValueError("Invalid task. Please choose 'light' or 'water'.")

    if args.test:
        args.scaler1_path = '/'.join(args.model_path.split('/')[:-1]) + f'/{args.task}_{args.seed}_scaler.joblib'
        if args.scaler_y:
            args.scaler2_path = '/'.join(args.model_path.split('/')[:-1]) + f'/{args.task}_{args.seed}_target_scaler.joblib'

    data_type = args.data_loc.split('/')[-1]
    args.outdir = os.path.join(args.outdir, args.NOW+'_'+data_type+'_'+args.task)

    outpath = Path(args.outdir)
    outpath.mkdir(parents=True, exist_ok=True)

    preprocessor = TreeDataset0(args)
    X_train, y_train, X_test, y_test = preprocessor.X_train, preprocessor.y_train, preprocessor.X_test, preprocessor.y_test
    X_train_scaled, y_train_scaled, X_test_scaled, y_test_scaled = preprocessor.X_train_scaled, preprocessor.y_train_scaled, preprocessor.X_test_scaled, preprocessor.y_test_scaled
    scaler1, scaler2 = preprocessor.scaler1, preprocessor.scaler2

    print(args)
    if args.test:
        print('Testing mode ...')
        test_model()
    else:
        print('Training mode ...')
        main()

