# SAS Flower Shop Simulator 🌸

## Overview
**SAS Florist Management** is a data-driven project designed to simulate and optimize the daily operations of a flower shop. The system leverages SAS to efficiently manage records, simulate business activities, and visualize key performance metrics. This project provides insights into sales trends, supply chain efficiency, and overall business health, helping florists make data-driven decisions.

## Problem Statement
In the highly dynamic flower shop industry, managing inventory, tracking sales, and ensuring timely deliveries are crucial for maintaining customer satisfaction and business profitability. A florist needs to:
- **Effectively manage customer orders, inventory, and supplier deliveries**
- **Analyze daily and monthly business performance**
- **Optimize inventory management to minimize waste while ensuring product availability**
- **Simulate real-world scenarios** such as supply chain disruptions or increased demand during peak seasons

Traditional management methods often rely on manual tracking, which can lead to inefficiencies and increased operational costs. This project aims to automate and streamline these processes using SAS.

## Features 🚀
- **Data Management**: Efficiently handles order records, customer data, and supplier details
- **Daily Operations Simulation**: Models real-world activities such as order processing and deliveries
- **Sales & Inventory Visualization**: Generates analytical reports and graphical insights
- **Automated Record Handling**: Implements automated scripts for adding, deleting, and editing records
- **Business Performance Analysis**: Provides insights into revenue trends and operational efficiency

## Project Structure 📂
```plaintext
📁 SAS-Florist-Management
│-- 📜 addRecords.sas          # Adds new orders and inventory updates
│-- 📜 deleteRecords.sas       # Handles record deletion for orders and customers
│-- 📜 editRecords.sas         # Modifies existing data entries
│-- 📜 getId.sas               # Retrieves unique record identifiers
│-- 📜 dane.sas                # Dataset initialization and sample data
│-- 📜 daySimulation.sas       # Simulates daily business operations
│-- 📜 deliverySimulation.sas  # Models supplier deliveries
│-- 📜 monthly_visualisation.sas # Creates sales and performance reports
│-- 📜 README.md               # Project documentation
```

## Technologies Used 🛠️
- **SAS Base** – Data processing and management
- **SAS Macro** – Automation of repetitive tasks
- **SAS Proc SQL** – Querying and managing relational datasets
- **SAS ODS Graphics** – Data visualization and reporting

## License 📄
This project is licensed under the **MIT License** – see the `LICENSE` file for details.

---

