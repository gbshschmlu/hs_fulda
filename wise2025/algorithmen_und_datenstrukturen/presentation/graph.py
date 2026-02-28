import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def create_graph_visualization(
        edges,
        node_colors=None,
        current_node=None,
        step_number=None,
        title="Graph Coloring",
        filename="graph.png",
        node_labels=None,
        figsize=(10, 8),
        node_size=2000,
        font_size=20
):
    """
    Creates a graph visualization for presentations

    edges: list of tuples, e.g., [(1,2), (1,3), (2,3)]
    node_colors: dict mapping node to color name, e.g., {1: 'red', 2: 'blue'}
    current_node: node to highlight with border (optional)
    step_number: step number to display (optional)
    title: title of the graph
    filename: output filename
    node_labels: dict mapping node to label, e.g., {1: 'A', 2: 'B'}
    """

    G = nx.Graph()
    G.add_edges_from(edges)

    nodes = list(G.nodes())

    if node_labels is None:
        node_labels = {node: str(node) for node in nodes}

    if node_colors is None:
        node_colors = {node: 'lightgray' for node in nodes}

    colors = [node_colors.get(node, 'lightgray') for node in nodes]

    pos = nx.spring_layout(G, seed=42, k=1.5, iterations=50)

    fig, ax = plt.subplots(figsize=figsize)

    nx.draw_networkx_edges(G, pos, width=3, alpha=0.6, edge_color='gray', ax=ax)

    for node in nodes:
        if node == current_node:
            nx.draw_networkx_nodes(
                G, pos,
                nodelist=[node],
                node_color=[node_colors.get(node, 'lightgray')],
                node_size=node_size,
                linewidths=5,
                edgecolors='black',
                ax=ax
            )
        else:
            nx.draw_networkx_nodes(
                G, pos,
                nodelist=[node],
                node_color=[node_colors.get(node, 'lightgray')],
                node_size=node_size,
                linewidths=2,
                edgecolors='black',
                ax=ax
            )

    nx.draw_networkx_labels(G, pos, node_labels, font_size=font_size,
                            font_weight='bold', font_color='white', ax=ax)

    if step_number is not None:
        ax.text(0.02, 0.98, f'Step {step_number}',
                transform=ax.transAxes, fontsize=24,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_title(title, fontsize=26, fontweight='bold', pad=20)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()

    print(f"Saved: {filename}")


def create_coloring_steps_example():
    """
    Example: Create step-by-step visualization of greedy coloring
    """

    edges = [
        (1, 2), (1, 3), (1, 4),
        (2, 3), (2, 5),
        (3, 4), (3, 5),
        (4, 6),
        (5, 6)
    ]

    node_labels = {1: 'A', 2: 'B', 3: 'C', 4: 'D', 5: 'E', 6: 'F'}

    steps = [
        {"colors": {}, "current": None, "step": 0, "title": "Initialer Graph"},
        {"colors": {1: 'red'}, "current": 1, "step": 1, "title": "Schritt 1: Knoten A → Rot"},
        {"colors": {1: 'red', 2: 'blue'}, "current": 2, "step": 2, "title": "Schritt 2: Knoten B → Blau"},
        {"colors": {1: 'red', 2: 'blue', 3: 'green'}, "current": 3, "step": 3, "title": "Schritt 3: Knoten C → Grün"},
        {"colors": {1: 'red', 2: 'blue', 3: 'green', 4: 'blue'}, "current": 4, "step": 4, "title": "Schritt 4: Knoten D → Blau"},
        {"colors": {1: 'red', 2: 'blue', 3: 'green', 4: 'blue', 5: 'red'}, "current": 5, "step": 5, "title": "Schritt 5: Knoten E → Rot"},
        {"colors": {1: 'red', 2: 'blue', 3: 'green', 4: 'blue', 5: 'red', 6: 'green'}, "current": 6, "step": 6, "title": "Schritt 6: Knoten F → Grün"},
    ]

    for step_data in steps:
        create_graph_visualization(
            edges=edges,
            node_colors=step_data["colors"],
            current_node=step_data["current"],
            step_number=step_data["step"] if step_data["step"] > 0 else None,
            title=step_data["title"],
            filename=f"graph_step_{step_data['step']}.png",
            node_labels=node_labels
        )


def create_custom_graph():
    """
    Create your own custom graph here
    """

    edges = [
        (1, 2), (2, 3), (3, 4), (4, 1)
    ]

    node_colors = {
        1: 'red',
        2: 'blue',
        3: 'red',
        4: 'blue'
    }

    create_graph_visualization(
        edges=edges,
        node_colors=node_colors,
        title="Custom Graph Example",
        filename="custom_graph.png"
    )


if __name__ == "__main__":
    create_coloring_steps_example()

    # create_custom_graph()
