# Monk Office Sage X3 Customisations

This repository contains a collection of Sage X3 customisations, business logic scripts, reports, and support modules developed for Monk Office operations. It is structured as a live customisation library used to extend the standard Sage X3 ERP behaviour with client-specific processing, reporting, inventory handling, and operational automation.

## Overview

The codebase is organised into functional areas that mirror a typical Sage X3 enhancement project:

- Specific processing
- Standard processing extensions
- Custom processing logic
- Reporting and views
- SQL assets and supporting data definitions

The project includes transaction-level custom logic, stock and warehousing actions, reporting automation, approval flows, and email-triggered business processes.

## Repository Structure

- [LIVE/01 - Specific Processing](01%20-%20Specific%20Processing)
  - Transaction-specific custom logic for core business processes and document handling.
- [LIVE/02 - Standard Processing](02%20-%20Standard%20Processing)
  - Extensions and overrides of standard Sage X3 processing routines.
- [LIVE/03 - Custom Processing](03%20-%20Custom%20Processing)
  - Business-specific automation such as reports, approvals, invoice handling, stock monitoring, and operational notifications.
- [LIVE/04 - Reports](04%20-%20Reports)
  - Report definitions and financial, sales, and stock reporting assets.
- [LIVE/05 - Views](05%20-%20Views)
  - View-layer definitions for business reporting and UI presentation.
- [LIVE/06 - Tools](06%20-%20Tools)
  - Utility and administration scripts.
- [LIVE/07 - Crystal Reports](07%20-%20Crystal%20Reports)
  - Crystal report templates and related objects.
- [SQL](../SQL)
  - Database objects, reporting SQL, and supporting scripts.

## What This Repository Is About

This repository represents a Sage X3 implementation layer for a business environment that requires additional logic beyond the default ERP functionality. Based on the files present, it handles:

- Purchase and sales order processing
- Intersite stock movement and location assignment
- Inventory and warehouse allocation logic
- Backorder and stock availability reporting
- Approval and notification workflows
- Automated email communication for operational actions
- Custom financial and operational reporting
- Support for document and file automation in a live ERP environment

## Important Notes

This is not a standalone application. It is a programming backup.

Before using or deploying these scripts in production:

- Validate them in a test or sandbox environment
- Confirm compatibility with your Sage X3 version
- Review local path references and environment-specific configuration
- Maintain strict source control and versioning practices