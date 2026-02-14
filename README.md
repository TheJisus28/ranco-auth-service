# 🔐 Ranco Auth Service

This microservice handles identity management, authentication, and session lifecycle for the **Ranco** ecosystem. Built with Go, it provides a secure and scalable foundation for distributed service communication.

## 🏗️ Architecture & Design
The service is designed around a decoupled data model to support multiple authentication providers while maintaining strict referential integrity.

* 📖 **[Data Dictionary](./docs/database/schema.md)**: Detailed entity-relationship definitions and field constraints.
* 📐 **ER Diagram**: [View Schema Visualization](./docs/database/diagram.png).

## 🗄️ Database Management
Schema evolution is handled through versioned migrations to ensure environment parity.

* 🛠️ **[Migration Guide](./migrations/README.md)**: Procedures for upgrading, reverting, and reconciling the database state.

## ⚖️ License and Usage

Copyright © 2026 Jesus Carrascal / Ranco. All rights reserved.

This repository is public for **portfolio demonstration purposes only**. No part of this software may be copied, modified, or distributed for commercial or private use without explicit written permission from the author.