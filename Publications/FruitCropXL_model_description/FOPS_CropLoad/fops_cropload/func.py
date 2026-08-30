import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from pathlib import Path

try:
    import plotly.graph_objects as go
    import plotly.io as pio
    from plotly.colors import sample_colorscale
except ImportError:
    go = None
    pio = None
    sample_colorscale = None


def plot_internode_waterPotential(test_node_df, y_values, outfile, target_name, model, type_,
                                  r2=None, view_elev=30, view_azim=-60,
                                  panel_title=None, panel_subtitle=None,
                                  colorbar_label=None, also_svg=False):
    # test_node_df and y_values contain data for a test tree (with all internodes) at multiple time points, so need to extract the data for a single time point
    unique_times = test_node_df['timestamp'].unique()
    # selected_time = np.random.choice(unique_times)
    selected_time = unique_times[0]  # for reproducibility during testing, you can change this to a fixed time
    mask = test_node_df['timestamp'] == selected_time
    print(f'Plotting internode water potential for time {selected_time}, {mask.sum()} internodes')
    node_df_t = test_node_df[mask].reset_index(drop=True)
    y_values_t = y_values[mask.values]


    # A little extra vertical room keeps the angled x-axis label fully visible.
    fig = plt.figure(figsize=(5.4, 5.4), facecolor="white")
    ax = fig.add_subplot(111, projection='3d')
    ax.set_facecolor("white")

    norm = plt.Normalize(vmin=min(y_values_t), vmax=max(y_values_t))
    cmap = cm.get_cmap('viridis')

    for i, row in node_df_t.iterrows():
        xs = [row['x'], row['endX']]
        ys = [row['y'], row['endY']]
        zs = [row['z'], row['endZ']]
        color = cmap(norm(y_values_t[i]))
        ax.plot(xs, ys, zs, color=color, linewidth=3, alpha=1)

    mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    mappable.set_array(y_values_t)
    colorbar = fig.colorbar(
        mappable,
        ax=ax,
        shrink=0.58,
        fraction=0.038,
        pad=0.015,
        aspect=24
    )
    colorbar.set_label(colorbar_label or target_name, fontsize=13, labelpad=7)
    colorbar.ax.tick_params(labelsize=11, length=3, width=0.8)


    # build parent-child connections
    parent_end_coords = {row['nodeID']: (row['endX'], row['endY'], row['endZ']) for _, row in node_df_t.iterrows()}
    for _, row in node_df_t.iterrows():
        nid, pid = row['nodeID'], row['parentID']
        if pid in parent_end_coords:
            x_p, y_p, z_p = parent_end_coords[pid]
            x_c, y_c, z_c = row['x'], row['y'], row['z']
            dx, dy, dz = x_c-x_p, y_c-y_p, z_c-z_p
            ax.quiver(x_p, y_p, z_p, dx, dy, dz, color='black', arrow_length_ratio=0.2, linewidth=1, alpha=0.8)


    if panel_title:
        fig.text(0.06, 0.985, panel_title, ha="left", va="top", fontsize=13, fontweight="bold")
        if panel_subtitle:
            fig.text(0.06, 0.945, panel_subtitle, ha="left", va="top", fontsize=11, color="0.30")
    else:
        title_prefix = " ".join(part for part in (str(model).strip(), str(type_).strip(), "Internode") if part)
        ax.set_title(f'{title_prefix} {target_name} at time {selected_time}, r2={r2:.3f}' if r2 is not None else f'{title_prefix} {target_name} at time {selected_time}')

    ax.set_xlabel('x (m)', labelpad=-4)
    ax.set_ylabel('y (m)', labelpad=3)
    ax.set_zlabel('z (m)', labelpad=3)
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.0, 1.0)
    ax.set_zlim(0.0, 4.2)
    ax.set_xticks([-1.5, 0.0, 1.5])
    ax.set_yticks([-1.0, 0.0, 1.0])
    ax.set_zticks([0.0, 1.0, 2.0, 3.0, 4.0])
    ax.tick_params(axis="both", which="major", labelsize=11, width=0.8, pad=0)
    ax.set_box_aspect((1.05, 0.72, 1.18))
    for axis in (ax.xaxis, ax.yaxis, ax.zaxis):
        axis._axinfo["grid"]["color"] = (0.84, 0.84, 0.84, 0.75)
        axis._axinfo["grid"]["linewidth"] = 0.55
        axis.set_pane_color((1.0, 1.0, 1.0, 1.0))
    ax.view_init(elev=float(view_elev), azim=float(view_azim))
    fig.subplots_adjust(left=-0.03, right=0.90, bottom=0.065, top=0.91)

    if outfile is None:
        plt.show()
    else:
        fig.savefig(outfile, bbox_inches='tight', dpi=300, facecolor="white")
        if also_svg:
            fig.savefig(str(Path(outfile).with_suffix(".svg")), bbox_inches='tight', facecolor="white")
            fig.savefig(str(Path(outfile).with_suffix(".pdf")), bbox_inches='tight', facecolor="white")
        plt.close()


def plot_internode_waterPotential_interactive(test_node_df, y_values, outfile, target_name, model, type_,
                                              r2=None, view_elev=30, view_azim=-60):
    """
    Interactive 3D version (HTML) of your matplotlib plot.

    Args
    ----
    test_node_df : pd.DataFrame. Must contain columns: ['timestamp','x','y','z','endX','endY','endZ','nodeID','parentID']
    y_values : np.ndarray or pd.Series Target values aligned with rows of test_node_df
    outfile : str or None
        Path to write an .html file. If None, returns a Plotly Figure (and shows it in notebooks).
    target_name : str
        Title for colorbar/legend (e.g., 'Water Potential (MPa)')
    model : str
    type_ : str (renamed from `type` to avoid shadowing built-in)
    """
    if go is None or pio is None or sample_colorscale is None:
        raise ImportError("Plotly is required only for interactive HTML output. Install it with: pip install plotly")
    if len(test_node_df) == 0:
        raise ValueError("test_node_df is empty.")

    # pick a single timestamp like your original code
    unique_times = test_node_df['timestamp'].unique()
    # selected_time = np.random.choice(unique_times)
    selected_time = unique_times[0]
    mask = test_node_df['timestamp'] == selected_time
    print(f'Plotting nodes for time {selected_time}, {mask.sum()} internodes')
    node_df_t = test_node_df.loc[mask].reset_index(drop=True)
    y_values_t = np.asarray(y_values)[mask.values]

    title_prefix = " ".join(part for part in (str(model).strip(), str(type_).strip(), "Internode") if part)
    title = f"{title_prefix} {target_name} at time {selected_time}, r2={r2:.3f}" if r2 is not None else f"{title_prefix} {target_name} at time {selected_time}"

    # Normalize for colors
    vmin = float(np.nanmin(y_values_t))
    vmax = float(np.nanmax(y_values_t))
    if np.isclose(vmin, vmax):
        vmax = vmin + 1e-9  # avoid zero range

    traces = []

    # 1) Internode segments: one trace per internode with its own color
    for i, row in node_df_t.iterrows():
        xs = [row['x'], row['endX']]
        ys = [row['y'], row['endY']]
        zs = [row['z'], row['endZ']]

        # Map y -> 0..1 for colorscale reference
        t = (y_values_t[i] - vmin) / (vmax - vmin)
        color = sample_colorscale('Viridis', t)[0]

        traces.append(
            go.Scatter3d(
                x=xs, y=ys, z=zs,
                mode="lines",
                line=dict(width=6, color=color, colorscale="Viridis"),
                hoverinfo="text",
                text=[f"nodeID={row['nodeID']}<br>{target_name}={y_values_t[i]:.4g}"]*2,
                showlegend=False
            )
        )

    # 2) Parent-child connectors (thin grey lines)
    parent_end_coords = {row['nodeID']: (row['endX'], row['endY'], row['endZ']) for _, row in node_df_t.iterrows()}

    connectors_x, connectors_y, connectors_z = [], [], []
    cones_x, cones_y, cones_z = [], [], []
    cones_u, cones_v, cones_w = [], [], []

    for _, row in node_df_t.iterrows():
        pid = row['parentID']
        if pid in parent_end_coords:
            x_p, y_p, z_p = parent_end_coords[pid]
            x_c, y_c, z_c = row['x'], row['y'], row['z']

            # line segment with None separators
            connectors_x += [x_p, x_c, None]
            connectors_y += [y_p, y_c, None]
            connectors_z += [z_p, z_c, None]

            # vector for optional arrow glyph
            dx, dy, dz = (x_c - x_p), (y_c - y_p), (z_c - z_p)
            cones_x.append(x_p); cones_y.append(y_p); cones_z.append(z_p)
            cones_u.append(dx);  cones_v.append(dy);  cones_w.append(dz)

    if connectors_x:
        traces.append(
            go.Scatter3d(
                x=connectors_x, y=connectors_y, z=connectors_z,
                mode="lines",
                # line=dict(width=2, color="rgba(80,80,80,0.7)"),
                line=dict(width=2, color="black"),
                hoverinfo="skip",
                showlegend=False
            )
        )

    # 3) Optional arrow glyphs using Cones (comment this block out if not desired)
    if cones_x:
        traces.append(
            go.Cone(
                x=cones_x, y=cones_y, z=cones_z,
                u=cones_u, v=cones_v, w=cones_w,
                sizemode="absolute",
                sizeref=max(np.linalg.norm([cones_u, cones_v, cones_w], axis=0))*0.07 if len(cones_u) else 1.0,
                showscale=False,
                anchor="tail",
                opacity=0.6
            )
        )

    # 4) Invisible marker trace to host the colorbar for y_values (because 3D line traces don't show a colorscale by themselves)
    traces.append(
        go.Scatter3d(
            x=node_df_t['x'], y=node_df_t['y'], z=node_df_t['z'],
            mode="markers",
            marker=dict(
                size=1,
                color=y_values_t,
                colorscale="Viridis",
                cmin=vmin, cmax=vmax,
                showscale=True,
                colorbar=dict(title=target_name)
            ),
            hoverinfo="skip",
            showlegend=False,
            opacity=0  # make markers invisible, just use for colorbar
        )
    )

    layout = go.Layout(
        title=title,
        scene=dict(
            xaxis_title="X",
            yaxis_title="Y",
            zaxis_title="Z",
            aspectmode="data"
        ),
        margin=dict(l=0, r=0, t=50, b=0)
    )

    fig = go.Figure(data=traces, layout=layout)

    if outfile is None:
        # return the figure so callers can .show() in notebooks or embed elsewhere
        return fig
    else:
        if not outfile.lower().endswith(".html"):
            outfile = outfile + ".html"
        pio.write_html(fig, file=outfile, auto_open=False, include_plotlyjs="cdn")
        # nothing returned; file written
