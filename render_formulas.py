import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

# Enable real LaTeX engine rendering
plt.rcParams.update({
    'text.usetex': True,
    'text.latex.preamble': r'\usepackage{amsmath}\usepackage{amssymb}\usepackage{amsfonts}',
    'font.family': 'serif',
})

out = r'D:\MCP\assets\formulas'
os.makedirs(out, exist_ok=True)

formulas = [
    ('eq_latency.png',
     r'$T_{\mathrm{total}}=T_{\mathrm{plan}}+N\cdot\bigl(T_{\mathrm{dispatch}}+T_{\mathrm{tool}}\bigr)+T_{\mathrm{post}}$'),
    ('eq_prob_chain.png',
     r'$\Pr(y\mid x)=\sum_{z}\Pr(y\mid z,x)\,\Pr(z\mid x)$'),
    ('eq_success_bound.png',
     r'$\Pr(\text{success})\;\ge\;\prod_{i=1}^{N}\bigl(1-\varepsilon_i\bigr)$'),
    ('eq_cost.png',
     r'$C=\alpha\, n_{\mathrm{in}}+\beta\, n_{\mathrm{out}}+\gamma\, N_{\mathrm{tool}}$'),
    ('eq_throughput.png',
     r'$\mathrm{Throughput}\approx\dfrac{K}{\mathbb{E}\!\left[T_{\mathrm{total}}\right]}$'),
    ('eq_tradeoff.png',
     r'$\mathcal{L}=\lambda_1\,\mathrm{Error}+\lambda_2\,\mathrm{Latency}+\lambda_3\,\mathrm{Cost}$'),
]

for fname, tex in formulas:
    fig, ax = plt.subplots(figsize=(10, 1.8))
    ax.text(0.5, 0.5, tex, fontsize=34, ha='center', va='center',
            transform=ax.transAxes, color='#111111')
    ax.axis('off')
    path = os.path.join(out, fname)
    fig.savefig(path, dpi=300, transparent=True, bbox_inches='tight', pad_inches=0.08)
    plt.close(fig)
    print(f'OK: {fname}')

print('ALL 6 FORMULAS RE-RENDERED WITH REAL LATEX ENGINE')
