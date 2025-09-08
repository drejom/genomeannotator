# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Pipeline Overview

nf-core/genomeannotator is a Nextflow bioinformatics pipeline for annotating eukaryotic genomes, particularly metazoans. It integrates multiple tools for protein/transcript alignment, RNA-seq analysis, gene prediction, and consensus gene building.

## Core Architecture

### Main Entry Points
- `main.nf` - Pipeline entry point, imports the main workflow
- `workflows/genomeannotator.nf` - Main workflow orchestrating all subworkflows
- `nextflow.config` - Global configuration and default parameters

### Pipeline Structure
```
workflows/genomeannotator.nf           # Main workflow
├── subworkflows/local/               # Custom subworkflows
│   ├── assembly_preprocess.nf        # Assembly filtering/preprocessing  
│   ├── augustus_pipeline.nf          # Ab-initio gene prediction
│   ├── spaln_align_protein.nf        # Protein alignment with SPALN
│   ├── rnaseq_align.nf              # RNA-seq alignment with STAR
│   ├── pasa_pipeline.nf             # Transcript-based gene building
│   ├── evm.nf                       # Evidence Modeler consensus
│   └── repeatmasker.nf              # Repeat masking
├── modules/local/                    # Custom process modules
└── modules/nf-core/modules/         # Standard nf-core modules
```

### Configuration System
- `conf/base.config` - Base execution settings
- `conf/modules.config` - Module-specific parameters
- `conf/test.config` - Minimal test dataset configuration
- `conf/test_full.config` - Full-scale test configuration
- `assets/` - Static configuration files, schemas, and reference data

## Development Commands

### Testing Pipeline

**🚨 CRITICAL TESTING REQUIREMENT 🚨**

**ALWAYS** use this exact testing command format - this is **MANDATORY**:

```bash
cd /scratch/domeally/tmp/ga && nextflow run /home/domeally/workspaces/genomeannotator -profile test,singularity --outdir . -resume
```

This is the **mandatory** testing approach per the CLAUDE.md instructions:
- **Must run from**: `/scratch/domeally/tmp/ga/` directory (purged every 3 weeks)
- **Must use**: `singularity` profile (not docker)
- **Must use**: `--outdir .` (current directory)
- **Must use**: `-resume` flag for efficiency
- **Must use**: Full absolute path to genomeannotator directory

**Other testing commands for reference only:**
```bash
# Full test with larger dataset (use same critical format)
cd /scratch/domeally/tmp/ga && nextflow run /home/domeally/workspaces/genomeannotator -profile test_full,singularity --outdir . -resume

# Docker testing (avoid unless singularity fails)
cd /scratch/domeally/tmp/ga && nextflow run /home/domeally/workspaces/genomeannotator -profile test,docker --outdir . -resume
```

### Development Environment
- **Test directory**: `/scratch/domeally/tmp/ga/` (purged every 3 weeks) - **CRITICAL**
- **Local testing**: Always use exact command format above before committing changes
- **CI/CD**: GitHub Actions automatically test changes on push/PR

### Linting and Quality Control
```bash
# nf-core linting (run via GitHub Actions)
nf-core lint .

# Markdown linting
markdownlint .

# AST-based code search and rewrite
ast-grep --help
```

### Code Search and Refactoring Tools
- **ast-grep**: Available for precise AST-based pattern matching and code transformation
  - Search and rewrite code at large scale using precise AST patterns
  - Useful for systematic code updates across multiple files
  - Commands: `ast-grep run`, `ast-grep scan`, `ast-grep test`
- **ripgrep (rg)**: Fast text search across files
  - Use for quick searches: `rg "pattern" --type nf`
  - More efficient than traditional grep for large codebases

## Key Components

### Evidence Integration Pipeline
1. **Assembly preprocessing** - Filter contigs, clean headers
2. **Evidence alignment**:
   - Proteins via SPALN
   - Transcripts via Minimap2  
   - RNA-seq via STAR
3. **Gene prediction**:
   - Ab-initio with AUGUSTUS
   - Transcript-based with PASA
4. **Consensus building** - EvidenceModeler integration
5. **Quality control** - BUSCO assessment

### Data Flow
- Input channels defined in `workflows/genomeannotator.nf:18-26`
- Evidence streams merged for EVM consensus in `subworkflows/local/evm.nf`
- Final outputs in GFF3 format compatible with GMOD databases

## Known Issues and Fixes

### RepeatMasker File Staging Issue
- **Problem**: `REPEATMASKER_STAGELIB` process fails with outdated file staging pattern
- **Error**: `cp: can't stat '/home/domeally/.nextflow/assets/nf-core/genomeannotator/assets/repeatmasker/my_genome.fa'`
- **Location**: `subworkflows/local/repeatmasker.nf`
- **Fix needed**: Replace `${baseDir}` file staging with proper Nextflow file channels
- **GitHub issue**: https://github.com/nf-core/genomeannotator/issues/18

### Input Validation
- Assembly file is mandatory (`params.assembly`)
- All evidence files are optional but recommended for quality
- BUSCO lineage should match target organism for QC

## Configuration Parameters

### Key Parameters
- `min_contig_size = 5000` - Filter small contigs
- `max_intron_size = 20000` - Gene model constraints
- `npart_size = 200000000` - Assembly partitioning for parallelization
- `min_prot_length = 35` - Protein filtering threshold

### Tool Flags
- `trinity = false` - Enable de-novo transcriptome assembly
- `pasa = false` - Enable PASA transcript-based gene building  
- `evm = false` - Enable EvidenceModeler consensus
- `ncrna = false` - Enable ncRNA prediction

## Testing Strategy
- Use `test` profile for development iteration
- GitHub Actions run comprehensive CI on push/PR
- Manual testing in `/scratch/domeally/tmp/ga/` before commits
- Only submit PRs to upstream nf-core/genomeannotator when explicitly requested
- always search the docs on the web if in doubt