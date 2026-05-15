# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.2] - 2026-05-13
### Added
- [GRD-1175](https://jira.oicr.on.ca/browse/GRD-1175)
- Added gencode as a required workflow input to support gencode version selection via olive assay_confirguration.
### Changed
- Branching by gencode version, analogous to other gencode-using workflows

### Changed
- Replaced hardcoded gencode version in module with a dinamic lookup via nested Map 

## [2.1.1] - 2025-09-25
### Changed
- [GRD-964](https://jira.oicr.on.ca/browse/GRD-964)
- Update workflow hg38 genome to genecode 44 
- Updated the regression test input file

## [2.1.0] - 2024-06-25
### Added
- [GRD-797](https://jira.oicr.on.ca/browse/GRD-797) - Add vidarr labels to outputs (changes to medata only).

## [2.0.2] - 2023-05-29
### Changed
- [GDR-543](https://jira.oicr.on.ca/browse/GDR543) Adjustments to the StarFusion Workflow. Modules definition moved to wdl.

## [Unreleased] - 2021-11-11
### Fixed
- [GP-2888](https://jira.oicr.on.ca/browse/GP-2888) Making RT tests more robust.

## [2.0.1] - 2020-05-31
### Changed
- Migrate to Vidarr.
