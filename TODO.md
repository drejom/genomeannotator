# nf-core/genomeannotator Development TODO

## Current Status

This is a **development-stage nf-core pipeline** for eukaryotic genome annotation (last updated >3 years ago, not yet released). We are working on fixing file staging issues and updating to modern nf-core template standards.

## Completed Work ✅

### 1. RepeatMasker File Staging Fix (Commit: 4499ca7)
- **Issue**: `REPEATMASKER_STAGELIB` process failed with outdated `${baseDir}` file staging pattern
- **Fix**: Updated to proper Nextflow DSL2 channels in `modules/local/repeatmasker/stagelib.nf` and `subworkflows/local/repeatmasker.nf`
- **Status**: ✅ **WORKING** - RepeatMasker processes now run successfully
- **GitHub Issue**: Resolves #18

### 2. Template Updates Applied (Commit: f6daf82)
- **Applied**: Selective merge of beneficial nf-core tools v2.14.1 template updates
- **Changes**:
  - Updated CI workflow (`actions/checkout@v4`, `setup-nextflow@v2`) 
  - Added concurrency controls and disk space cleanup
  - Modernized linting workflow with pre-commit approach
  - Added `.pre-commit-config.yaml` with Prettier and EditorConfig
  - Updated Nextflow test versions to 23.04.0 and latest-everything
  - Security improvements with action hash pinning
- **Strategy**: Preserved all genomeannotator-specific functionality while updating infrastructure

## Current Issues ❌

### Augustus File Staging Issue (In Progress)
- **Problem**: `AUGUSTUS_STAGECONFIG` fails with `cp: can't stat 'config/*': No such file or directory`
- **Root Cause**: Container path `/usr/local/config` not properly resolved in Nextflow channels
- **Current State**: Attempted fixes in progress but not working
- **Files**: `modules/local/augustus/stageconfig.nf`, `workflows/genomeannotator.nf`
- **Status**: 🚧 Uncommitted changes - DO NOT commit until fixed

## Priority TODO List

### 1. 🎯 **HIGHEST PRIORITY: Complete Template Updates**
- **Current**: Applied v2.14.1 template (May 2024)
- **Target**: Latest nf-core/tools v3.3.2 (July 2025)
- **Gap**: ~1 year of template improvements missing
- **Tool Available**: `nf-core pipelines sync` command can update to latest template
- **Action**: 
  ```bash
  # Use nf-core tool to sync with latest template
  nf-core pipelines sync
  ```
- **Note**: This pipeline has no newer automated PRs because it's unreleased/unmaintained

### 2. 🔧 **Fix Augustus File Staging Issue**
- **Current Problem**: Augustus config directory path resolution failure
- **Approach Needed**: 
  - Research proper nf-core patterns for container configuration directories
  - May benefit from newer template updates (v3.x has improved container handling)
  - Consider Augustus-specific documentation for containerized environments
- **Files to Fix**: 
  - `modules/local/augustus/stageconfig.nf`
  - `workflows/genomeannotator.nf`

## Testing Requirements

### Critical Testing Command (MANDATORY)
```bash
cd /scratch/domeally/tmp/ga && nextflow run /home/domeally/workspaces/genomeannotator -profile test,singularity --outdir . -resume
```

**Requirements**:
- Must run from `/scratch/domeally/tmp/ga/` (purged every 3 weeks)
- Must use `singularity` profile (not docker)
- Must use `--outdir .` (current directory)
- Must use `-resume` flag for efficiency
- Must use full absolute path to genomeannotator directory

## Development Context

### Repository Status
- **Fork**: `drejom/genomeannotator` (our working fork)
- **Upstream**: `nf-core/genomeannotator` (development stage, unmaintained)
- **Branch**: `dev`
- **Current Commits**: 2 commits ahead of origin/dev

### Tools Available
- **nf-core**: CLI tool available for template syncing (`nf-core --help`)
- **ast-grep**: Precise AST-based pattern matching (`ast-grep --help`)
- **ripgrep (rg)**: Fast text search (`rg "pattern" --type nf`)

### Key Files Modified
- ✅ `modules/local/repeatmasker/stagelib.nf` (RepeatMasker fix - committed)
- ✅ `subworkflows/local/repeatmasker.nf` (RepeatMasker fix - committed)
- ✅ `.github/workflows/ci.yml` (template update - committed)
- ✅ `.github/workflows/linting.yml` (template update - committed)
- ✅ `.pre-commit-config.yaml` (template update - committed)
- 🚧 `modules/local/augustus/stageconfig.nf` (Augustus fix - in progress)
- 🚧 `workflows/genomeannotator.nf` (Augustus fix - in progress)

## Pipeline Architecture

### Core Components
- **Main Entry**: `main.nf` → `workflows/genomeannotator.nf`
- **Evidence Processing**: Proteins (SPALN), Transcripts (Minimap2), RNA-seq (STAR)
- **Gene Prediction**: Augustus (ab-initio), PASA (transcript-based)
- **Consensus**: EvidenceModeler integration
- **QC**: BUSCO assessment

### Known Working Parts
- Assembly preprocessing ✅
- RepeatMasker pipeline ✅ (after our fix)
- SPALN protein alignment ✅
- RNA-seq alignment ✅

### Known Issues
- Augustus configuration staging ❌ (container path resolution)

## Next Session Priorities

1. **Template Update**: Use `nf-core pipelines sync` to get latest v3.3.2 template
2. **Augustus Fix**: Resolve container configuration directory access after template update
3. **Full Pipeline Test**: Verify both RepeatMasker and Augustus work together
4. **Documentation**: Update CLAUDE.md with final working solution

## Additional Notes

- Pipeline targets metazoan genome annotation but should work for other eukaryotes
- Uses Nextflow DSL2 with containerized processes (Singularity preferred)
- Original pipeline developed by Marc P. Hoeppner (@marchoeppner)
- Test data uses C. elegans genome subset