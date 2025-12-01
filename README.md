# Libertas

- - - - - -

![Overview](libertas.png)

Libertas is a framework for efficiently performing privacy-preserving computation on decentralized contexts such as personal data stores.
It combines (Secure) Multi-Party Computation (MPC) with Solid (Social Linked Data), addressing the key challenges of decentralization. It also demonstrates how Differential Privacy can be employed in this context, leading to both input and output privacy.

Preprint available at https://arxiv.org/abs/2309.16365

[This repo](https://github.com/OxfordHCC/libertas) is the indexer repository for our prototype implementation. The implementation contains several parts, in different repositories:

- [MPC App](https://github.com/OxfordHCC/solid-mpc-app): This repository contains the source code for the example MPC App for performing MPC in Libertas
- [Agent services](https://github.com/OxfordHCC/solid-mpc): This repository contains the source code for agent services (for encryption agent and computation agent)
- [Specification](./spec/index.html): The specification (using ReSpec) of Libertas, containing details of the protocol and interactions
    - If not rendered, try [this link instead](https://oxfordhcc.github.io/libertas/spec/index.html)

Please refer to the README in each repository for further details.

## Quick Setup

```bash
# 1. Clone and setup
./setup.sh
./scripts/setup-services.sh

# 2. Configure credentials
./scripts/configure-credentials.sh

# 3. Start services
./scripts/start-services.sh

# 4. Access MPC App at http://localhost:5173
```

See [SETUP.md](./SETUP.md) for complete setup and run instructions.


## Citing this work

This paper has been accepted by ACM CSCW conference 2025, which will be held in November 2025. You can cite this work like this:

> Rui Zhao, Naman Goel, Nitin Agrawal, Jun Zhao, Jake Stein, Wael S Albayaydh, Ruben Verborgh, Reuben Binns, Tim Berners-Lee, and Nigel Shadbolt. 2025. Libertas: Privacy-Preserving Collaborative Computation for Decentralised Personal Data Stores. Proc. ACM Hum.-Comput. Interact. 9, 7, Article 309 (November 2025), 30 pages. https://doi.org/10.1145/3757490

Alternatively, you can also cite the arxiv version for the time being:

```
@misc{zhao2023libertas,
      title={Libertas: Privacy-Preserving Computation for Decentralised Personal Data Stores}, 
      author={Rui Zhao and Naman Goel and Nitin Agrawal and Jun Zhao and Jake Stein and Ruben Verborgh and Reuben Binns and Tim Berners-Lee and Nigel Shadbolt},
      year={2023},
      eprint={2309.16365}
}
```

