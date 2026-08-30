import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.cm as cm
from mpl_toolkits.mplot3d import Axes3D,proj3d
import numpy as np
import plotly.graph_objects as go
import os
import seaborn as sns
from sklearn.metrics import r2_score
import pandas as pd
import matplotlib.patches as patches
from matplotlib.collections import PatchCollection
from matplotlib.patches import Polygon as MplPolygon

def get_depth(x, y, z, ax):
    x2d, y2d, z2d = proj3d.proj_transform(x, y, z, ax.get_proj())
    # depth = np.sqrt(x2d ** 2 + y2d ** 2 + z2d ** 2)
    return z2d


def plot_structure(df, elev, azim, test_mask, edge_index, args):
    if not args.filename:
        args.filename = args.dataset

    df['cX'] = (df['x'] + df['endX']) / 2
    df['cY'] = (df['y'] + df['endY']) / 2
    df['cZ'] = (df['z'] + df['endZ']) / 2
    centroids = df[['cX', 'cY', 'cZ']].mean()

    fabs = df['fabs'].values
    norm = plt.Normalize(fabs.min(), fabs.max())
    cmap = cm.get_cmap()

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')

    # shooting angle, in pyplot, azimuth is the angle between the x-axis and the projection of the point onto the xy-plane
    # but in geometry, azimuth is the angle between the north direction (y-axis) and the projection of the point onto the xy-plane
    # so we need to adjust the azimuth angle by subtracting it from 90 degrees
    # convert to geometry azimuth
    ax.view_init(elev=elev, azim=(90 - azim)%360)

    depths = []  # to store the depth of each point
    for idx, row in df.iterrows():
        depth = get_depth(row['cX'], row['cY'], row['cZ'], ax)
        depths.append(depth)

    sorted_index = [n for _, n in sorted(zip(depths, df.index), key=lambda t:t[0], reverse=True)]  # sort nodes by depth
    for idx in sorted_index:
        row = df.iloc[idx]
        xs = [row['x'], row['endX']]
        ys = [row['y'], row['endY']]
        zs = [row['z'], row['endZ']]
        color = cmap(norm(row['fabs']))

        if test_mask and args.mark_test_instances:
            if idx in test_mask:
                ax.plot(xs, ys, zs, color='red', linewidth=4, alpha=1)

        ax.plot(xs, ys, zs, color=color, linewidth=3, alpha=1)

    if edge_index:
        for [idx_i, idx_j] in edge_index.t():
            row_i = df.iloc[int(idx_i)]
            row_j = df.iloc[int(idx_j)]
            xs = [row_i['x'], row_j['x']]
            ys = [row_i['y'], row_j['y']]
            zs = [row_i['z'], row_j['z']]
            ax.plot(xs, ys, zs, color='black', linewidth=0.7, alpha=0.7)

    ax.scatter(centroids['cX'], centroids['cY'], centroids['cZ'], color='red', s=30, label='Centroid')

    # print(test_mask)
    # print(centroids['cX'])
    # ax.scatter(xs[test_mask], ys[test_mask], zs[test_mask], facecolor='none', edgecolor='r', s=50, linewidths=1, alpha=0.5, label='Test Set')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_title('3D Structure of Leaf, {}, elev: {}, azim: {}'.format(args.filename, elev, azim))

    sm = cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, shrink=0.6)
    cbar.set_label('Fabs')
    ax.legend(loc='upper right')
    plt.tight_layout()

    plt.savefig(os.path.join(args.outdir, "3D_structure_{}_{}-{}.png").format(elev, azim, args.filename), dpi=300)




def plot_structure1(df, elev, azim, test_mask, edge_index, args):
    df['cX'] = (df['x'] + df['endX']) / 2
    df['cY'] = (df['y'] + df['endY']) / 2
    df['cZ'] = (df['z'] + df['endZ']) / 2
    centroids = df[['cX', 'cY', 'cZ']].mean()

    fabs = df['fabs'].values
    norm = plt.Normalize(fabs.min(), fabs.max())
    cmap = cm.get_cmap()

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')

    # shooting angle, in pyplot, azimuth is the angle between the x-axis and the projection of the point onto the xy-plane
    # but in geometry, azimuth is the angle between the north direction (y-axis) and the projection of the point onto the xy-plane
    # so we need to adjust the azimuth angle by subtracting it from 90 degrees
    # convert to geometry azimuth
    ax.view_init(elev=elev, azim=(90 - azim)%360)

    for idx, row in df.iterrows():
        xs = [row['x'], row['endX']]
        ys = [row['y'], row['endY']]
        zs = [row['z'], row['endZ']]
        color = cmap(norm(row['fabs']))

        if test_mask and args.mark_test_instances:
            if idx in test_mask:
                ax.plot(xs, ys, zs, color='red', linewidth=4, alpha=1)

        ax.plot(xs, ys, zs, color=color, linewidth=3, alpha=1)


    # print(edge_index.shape)
    if edge_index:
        for [idx_i, idx_j] in edge_index.t():
            row_i = df.iloc[int(idx_i)]
            row_j = df.iloc[int(idx_j)]
            xs = [row_i['x'], row_j['x']]
            ys = [row_i['y'], row_j['y']]
            zs = [row_i['z'], row_j['z']]
            ax.plot(xs, ys, zs, color='black', linewidth=0.7, alpha=0.7)

    ax.scatter(centroids['cX'], centroids['cY'], centroids['cZ'], color='red', s=30, label='Centroid')

    # print(test_mask)
    # print(centroids['cX'])
    # ax.scatter(xs[test_mask], ys[test_mask], zs[test_mask], facecolor='none', edgecolor='r', s=50, linewidths=1, alpha=0.5, label='Test Set')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_aspect('equal')
    ax.set_title('3D Structure of Leaf, {}, elev: {}, azim: {}'.format(args.dataset, elev, azim))


    sm = cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, shrink=0.6)
    cbar.set_label('Fabs')
    ax.legend(loc='upper right')
    plt.tight_layout()
    plt.savefig(os.path.join(args.outdir, "3D_structure_{}_{}.png").format(elev, azim), dpi=300)
    # plt.show()
    plt.close()

def plot_structure_dynamic(df, test_mask, edge_index, args):
    if not args.filename:
        args.filename = args.dataset

    df['cX'] = (df['x'] + df['endX']) / 2
    df['cY'] = (df['y'] + df['endY']) / 2
    df['cZ'] = (df['z'] + df['endZ']) / 2
    centroids = df[['cX', 'cY', 'cZ']].mean()

    lines = []  # leaf
    fabs = df['fabs'].values
    norm = plt.Normalize(fabs.min(), fabs.max())
    cmap = cm.get_cmap('viridis')

    for idx, row in df.iterrows():
        color_val = row['fabs']
        rgba = cmap(norm(color_val))
        hex_color = mcolors.to_hex(rgba)

        if test_mask and args.mark_test_instances:  # test leaf, add red border
            if idx in test_mask:
                lines.append(
                    go.Scatter3d(
                        x=[row['x'], row['endX']],
                        y=[row['y'], row['endY']],
                        z=[row['z'], row['endZ']],
                        mode='lines',
                        line=dict(color='red', width=10),
                        hoverinfo='text',
                        text=f'Fabs: {row["fabs"]:.2f}',
                        name='test leaf',
                        showlegend=False
                    ))

        lines.append(
            go.Scatter3d(
                x=[row['x'], row['endX']],
                y=[row['y'], row['endY']],
                z=[row['z'], row['endZ']],
                mode='lines',
                # line=dict(
                #     color=row['fabs'],
                #     width=5,
                #     colorscale='YlGn',
                #     showscale=True,
                #     cmin=fabs.min(),
                #     cmax=fabs.max(),
                # ),
                line=dict(color=hex_color, colorscale='viridis', width=8, showscale=True, cmin=fabs.min(),
                          cmax=fabs.max()),
                hoverinfo='text',
                text=f'Fabs: {row["fabs"]:.2f}',
                name='leaf',
                showlegend=False
            ))

    centroid_point = go.Scatter3d(
        x=[centroids['cX']],
        y=[centroids['cY']],
        z=[centroids['cZ']],
        mode='markers',
        marker=dict(size=7, color='red', opacity=1),
        name='Centroid',
        showlegend=False
    )

    # plot the edges
    if edge_index:
        for k, [idx_i, idx_j] in enumerate(edge_index.t()):
            # if k % 50 == 0:  # to reduce the number of edges plotted
            row_i = df.iloc[int(idx_i)]
            row_j = df.iloc[int(idx_j)]
            xs = [row_i['x'], row_j['x']]
            ys = [row_i['y'], row_j['y']]
            zs = [row_i['z'], row_j['z']]
            lines.append(
                go.Scatter3d(
                    x=xs,
                    y=ys,
                    z=zs,
                    mode='lines',
                    line=dict(color='black', width=3),
                    hoverinfo='none',
                    name='edge',
                    showlegend=False
                ))
    fig = go.Figure(data=lines + [centroid_point])
    fig.update_layout(title='3D Structure of Leaf %s' % args.filename,
                      scene=dict(xaxis_title='X', yaxis_title='Y', zaxis_title='Z'),
                      coloraxis_colorbar=dict(title='Fabs'),
                      margin=dict(l=0, r=0, b=0, t=30))  # coloraxis_colorbar=dict(title='Fabs'), showlegend=False
    # fig.show()
    fig.write_html(os.path.join(args.outdir, "3D_structure_dynamic-%s.html"%args.filename), auto_open=False)
    plt.close()


def plot_projected_polygon(projected_polygons, occlusion_ratios, args):
    fig, ax = plt.subplots(figsize=(10, 10))
    # for i, poly in enumerate(projected_polygons):
    for i, poly in reversed(list(enumerate(projected_polygons))):
        if not poly.is_empty:
            if occlusion_ratios[i] == 0:
                color = (0.9, 0.9, 1)
            else:
                color = (1.0 - occlusion_ratios[i], 1.0 - occlusion_ratios[i], 1)  # 遮挡率越高，颜色越深蓝
            # color = (0.5, 0.5, 1 - occlusion_ratios[i])  # 蓝色渐变
            patch = MplPolygon(list(poly.exterior.coords), closed=True, color=color, edgecolor='black', alpha=0.7)
            ax.add_patch(patch)
    ax.autoscale()
    ax.set_aspect('equal')
    ax.set_title('Projected Leaf Polygons with Occlusion Ratios')
    plt.xlabel("Projection X")
    plt.ylabel("Projection Y")
    # plt.grid(True)
    # plt.show()
    plt.tight_layout()
    plt.savefig(os.path.join(args.outdir, 'projected_polygons.png'), dpi=300)
    plt.close()

def plot_projected_rectangles(rectangles, values, val_name, args):
    if not hasattr(args, 'filename'):
        args.filename = ''
    rectangles = np.array(rectangles)
    z_means = rectangles[:,:,2].mean(axis=1)
    sort_indices = np.argsort(z_means)
    rectangles_sorted = rectangles[sort_indices]
    values_sorted = np.array(values)[sort_indices]

    patches = []
    colors = []
    for i, rect in enumerate(rectangles_sorted):
        xy = rect[:, :2]
        polygon = MplPolygon(xy, closed=True, edgecolor='black', facecolor='none', linewidth=1.5)
        patches.append(polygon)
        colors.append(values_sorted[i])
    fig, ax = plt.subplots(figsize=(8, 8))
    collection = PatchCollection(patches, cmap='viridis', edgecolor='black', linewidths=0.5)
    collection.set_array(np.array(colors))
    ax.add_collection(collection)
    ax.autoscale_view()

    cbar = plt.colorbar(collection, ax=ax)
    cbar.set_label(val_name)
    ax.set_title('Projected Leaves in %s with %s'%(args.filename, val_name))
    ax.set_xlabel("Projection X")
    ax.set_ylabel("Projection Y")
    ax.set_aspect('equal')
    plt.tight_layout()
    plt.savefig(os.path.join(args.outdir, 'projected_leaves_%s_%s.png'%(val_name, args.filename)), dpi=300)
    plt.close()

def plot_correlations(corr_df, args):
    if not hasattr(args, 'filename'):
        args.filename = ''
    corr_matrix = corr_df.astype(float).fillna(0)
    plt.figure(figsize=(len(corr_matrix.columns)//2+2, len(corr_matrix.columns)//2))
    ax = sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', vmin=-1, vmax=1, fmt='.2f')
    # sns.heatmap(corr_matrix, annot=True, cmap='bwr', vmin=-1, vmax=1, fmt='.2f')

    for label in ax.get_xticklabels():
        if label.get_text() in args.targets:
            label.set_color('red')
            # label.set_fontsize(10)
            # label.set_fontweight('bold')
        if label.get_text() in args.feature_cols:
            label.set_color('blue')
            # label.set_fontsize(10)
            # label.set_fontweight('bold')

    for label in ax.get_yticklabels():
        if label.get_text() in args.targets:
            label.set_color('red')
            # label.set_fontsize(10)
            # label.set_fontweight('bold')
        if label.get_text() in args.feature_cols:
            label.set_color('blue')
            # label.set_fontsize(10)
            # label.set_fontweight('bold')

    plt.xticks(rotation=45, ha='right', fontsize=13)
    plt.yticks(rotation=0, fontsize=13)
    plt.title('Pearson Correlation between features')
    plt.tight_layout()
    # plt.savefig('./corr_matrix2.pdf')
    plt.savefig(os.path.join(args.outdir, 'corr_matrix_%s.pdf'%args.filename), dpi=300)
    # plt.show()
    plt.close()


def plot_predicted_actual(predicted: list[float], actual: list[float], outfile: str | None = None, target_name: str | None=None, model: str|None=None) -> None:
    """Plot predicted vs actual.

	Args:
		predicted (list[float]): Predicted values.
		actual (list[float]): Actual values.
		outfile (str | None, optional): The outdir. Defaults to None.
	"""
    plt.figure()
    pred_df = pd.DataFrame({"predicted": predicted, "actual": actual})
    r2 = r2_score(pred_df["actual"], pred_df["predicted"])

    plt.scatter(pred_df["actual"], pred_df["predicted"], color="teal")
    plt.xlabel("Actual "+ (f"({target_name})" if target_name else ""))
    plt.ylabel("Predicted "+ (f"({target_name})" if target_name else ""))
    plt.title(f"{model} Predicted vs Actual (R² = {r2:.3f})")

    min_val = min(pred_df["actual"].min(), pred_df["predicted"].min())
    max_val = max(pred_df["actual"].max(), pred_df["predicted"].max())
    plt.plot([min_val, max_val], [min_val, max_val], color="gray", linestyle="--")

    if outfile is None:
        plt.show()
    else:
        plt.savefig(outfile)
        plt.close()
