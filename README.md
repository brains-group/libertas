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
# 1. Clone repository (with submodules)
git clone --recursive https://github.com/OxfordHCC/libertas.git
cd libertas

# Or if already cloned, initialize submodules
git submodule update --init --recursive

# 2. Run setup
./setup.sh
./scripts/setup-services.sh

# 3. Configure credentials
./scripts/configure-credentials.sh

# 4. Start services
./scripts/start-services.sh

# 5. Access MPC App at http://localhost:5173
```

See [SETUP.md](./SETUP.md) for complete setup instructions.  
See [SUBMODULES.md](./SUBMODULES.md) for information about git submodules.

## Local Solid Community Server Setup

For local development and testing, you can set up a local Solid Community Server. This allows you to test Libertas without external dependencies.

### Quick Setup

```bash
# 1. Set up local Solid server
./scripts/setup-local-solid.sh

# 2. Start the Solid server
./scripts/start-solid-server.sh

# 3. Configure Libertas to use local IDP
./scripts/configure-local-idp.sh encryption-agent@localhost
```

The server will start on **http://localhost:3000**

### Authentication Endpoints

The Community Solid Server provides the following authentication endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| **Registration**<br>`http://localhost:3000/.account/login/password/register/` | POST | Create a new account |
| **Login**<br>`http://localhost:3000/.account/login/password/` | POST | Password-based login |
| **Forgot Password**<br>`http://localhost:3000/.account/login/password/forgot/` | POST | Request password reset |
| **Reset Password**<br>`http://localhost:3000/.account/login/password/reset/` | POST | Reset password with token |
| **Account Info**<br>`http://localhost:3000/.account/` | GET | Get account controls and available endpoints (returns JSON) |
| **List Login Methods**<br>`http://localhost:3000/.account/login/` | GET | Get available authentication methods |

### Registering Accounts

1. **Open browser**: http://localhost:3000
2. **Click "Register"** or go directly to: http://localhost:3000/.account/login/password/register/
3. **Create accounts** using email addresses:
   - **Encryption Agent**: `encryption-agent@localhost`
   - **Data Provider**: `data-provider@localhost`
   - **Computation Requestor**: `requestor@localhost`
4. **Note your WebIDs** (check your profile after registration):
   - Format: `http://localhost:3000/[identifier]/profile/card#me`
   - The identifier is derived from your email address

### Important Notes

- **Email-based registration**: Community Solid Server uses email addresses instead of usernames
- **WebID linking**: After registration, you need to link a WebID to your account (see account settings)
- **No trusted apps**: Community Solid Server doesn't have "Authorized Applications" - password authentication works directly for local development
- **Permissions**: You still need to grant read permissions on data resources using WebIDs

For more detailed information, see:
- [LOCAL_SOLID_SETUP.md](./LOCAL_SOLID_SETUP.md) - Local Solid server setup
- [SOLID_LOGIN_ENDPOINTS.md](./SOLID_LOGIN_ENDPOINTS.md) - Authentication endpoints
- [UPLOAD_FILES_GUIDE.md](./UPLOAD_FILES_GUIDE.md) - File upload instructions
- [SUBMODULES.md](./SUBMODULES.md) - Git submodules guide

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

