import os, ast
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from plot import plot_correlations
import joblib

class TreeDataset0():
    def __init__(self, args):
        self.args = args
        self.scaler1 = StandardScaler()
        self.scaler2 = StandardScaler()
        self.preprocess()

    def preprocess(self):
        if os.path.exists(self.args.data_loc):
            self.train_data = pd.read_csv(os.path.join(self.args.data_loc, f'merged_{self.args.task}_train.csv'))
            self.test_data = pd.read_csv(os.path.join(self.args.data_loc, f'merged_{self.args.task}_test.csv'))
        else:
            raise FileNotFoundError(f"Data location {self.args.data_loc} does not exist.")

        print('Training set shape: ', self.train_data.shape, ', Test set shape: ', self.test_data.shape)
        print(self.train_data.columns)

        # further filter out samples with low solarElevation and high incoming Radiation
        # self.train_data = self.train_data[(self.train_data['solarElevation'] >= 16)&(self.train_data['incomingRadiation'] >= 178)]

        train_targets = self.train_data[self.args.targets.split(',')]
        test_targets = self.test_data[self.args.targets.split(',')]
        self.train_targets, self.test_targets = train_targets, test_targets
        print('train_targets: ', train_targets.shape, ', test_targets: ', test_targets.shape)

        if self.args.task.__contains__('light'):
            self.feature_cols = ['hourOfDay', 'rowOrientation', 'rowDistance', 'azimuth', 'solarElevation', 'leafAreaPerPlant', 'fDiffuseLight', 'incomingRadiation']
        elif self.args.targets.__contains__('water'):
            self.feature_cols = ['hourOfDay', 'azimuth', 'solarElevation', 'leafAreaPerPlant', 'fDiffuseLight', 'incomingRadiation', 'Ta', 'rh', 'wind', 'soilWaterPotential',
                                'P:eq1_b', 'P:phi_stem', 'P:Grmax_a', 'P:slope_Jmax', 'P:cx1',]
        else:
            raise ValueError("Invalid task. Please choose 'light' or 'water'.")

        self.args.feature_cols = self.feature_cols


        X_train = self.train_data[self.feature_cols].fillna(0)
        y_train = self.train_targets.fillna(0)
        X_test = self.test_data[self.feature_cols].fillna(0)
        y_test = self.test_targets.fillna(0)
        
        # normalize features
        if self.args.standardize:
            if self.args.test:
                self.scaler1 = joblib.load(self.args.scaler1_path)
                X_train_scaled = self.scaler1.transform(X_train)
                X_test_scaled = self.scaler1.transform(X_test)

                if self.args.scaler_y:
                    self.scaler2 = joblib.load(self.args.scaler2_path)
                    y_train_scaled = self.scaler2.transform(y_train)
                    y_test_scaled = self.scaler2.transform(y_test)
                else:
                    y_train_scaled, y_test_scaled = y_train, y_test
            else:
                X_train_scaled = self.scaler1.fit_transform(X_train)
                X_test_scaled = self.scaler1.transform(X_test)
                joblib.dump(self.scaler1, os.path.join(self.args.outdir, f'{self.args.task}_{self.args.seed}_scaler.joblib'))
                if self.args.scaler_y:
                    y_train_scaled = self.scaler2.fit_transform(y_train)
                    y_test_scaled = self.scaler2.transform(y_test)
                    joblib.dump(self.scaler2, os.path.join(self.args.outdir, f'{self.args.task}_{self.args.seed}_target_scaler.joblib'))
                else:
                    y_train_scaled, y_test_scaled = y_train, y_test
        else:
            X_train_scaled, X_test_scaled, y_train_scaled, y_test_scaled = X_train, X_test, y_train, y_test

        if self.args.plot_feature_correlations:
            self.calc_feature_corr(X_train, y_train)

        self.X_train, self.y_train, self.X_test, self.y_test = X_train, y_train, X_test, y_test
        self.X_train_scaled, self.y_train_scaled, self.X_test_scaled, self.y_test_scaled = X_train_scaled, y_train_scaled, X_test_scaled, y_test_scaled

        print('X_train: ', self.X_train.shape, 'y_train: ', self.y_train.shape, 'X_test: ', self.X_test.shape, 'y_test: ', self.y_test.shape)


    def calc_feature_corr(self, X, Y):
        if isinstance(X, np.ndarray):
            X = pd.DataFrame(X, columns=self.feature_cols, index=np.arange(len(X)))
        if isinstance(Y, np.ndarray):
            Y = pd.DataFrame(Y, columns=self.args.targets.split(','), index=np.arange(len(Y)))

        combined_df = pd.concat([X, Y], axis=1)
        correlations = combined_df.corr()
        # print('Correlations:\n', correlations)

        corr_df = pd.DataFrame(correlations)
        corr_df.to_csv(os.path.join(self.args.outdir, 'feature_correlations.csv'), index=True)
        plot_correlations(corr_df, self.args)
