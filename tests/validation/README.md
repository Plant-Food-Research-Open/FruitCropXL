# Validation tests

The validation testing class executes model scenarios and compares synthetic
outputs with maintained validation datasets.

Only scenario fixtures and their shared validation runners live here. Portable
smoke testing is under `tests/smoke_test/`, diagnostics are under
`tests/diagnosis/`, and packaged-project checks are under `tests/gsz_test/`.
See `tests/README.md` for the full ownership map.

## Table of Contents

- [Validation tests](#validation-tests)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Which script to use](#which-script-to-use)
    - [1. CI-equivalent local validation](#1-ci-equivalent-local-validation)
    - [2. Multi-scenario local validation](#2-multi-scenario-local-validation)
    - [3. DAI helper](#3-dai-helper)
    - [4. Packaged-project validation](#4-packaged-project-validation)
    - [5. Canonical Apptainer runner](#5-canonical-apptainer-runner)
    - [6. Portable smoke test](#6-portable-smoke-test)
    - [7. Diagnostic helpers](#7-diagnostic-helpers)
    - [Logs and outputs](#logs-and-outputs)
    - [Expected output](#expected-output)
  - [Configuration](#configuration)
    - [`params.yaml` - Test parameter configuration](#paramsyaml---test-parameter-configuration)
    - [`scenario.yaml` - Scenario configuration](#scenarioyaml---scenario-configuration)
  - [Adding tests for scenarios](#adding-tests-for-scenarios)

## Usage

### Embedded JUnit inventory

The `XrunTests` suite includes focused numerical tests as well as graph-level smoke tests. The explicit-carbon boundary tests verify:

| Test area | Assertions |
| --- | --- |
| PlantBase folded boundary | zero, near-zero and non-finite folded coefficients, negative, sub-floor or infinite roots, and invalid transformed sugar retain the preceding valid carbon potential, or use the positive floor when no valid preceding state exists |
| Finite transformed state | every guarded outcome retains finite positive PlantBase `cpb`, `cpt` and phloem sugar concentration; the unsatisfied boundary residual is preserved rather than forced to zero |
| Fallback diagnostics | current fallback flag and reason, cumulative fallback count, folded denominator and boundary residual are populated and fixed in the diagnostic-table schema |
| Normal-path equivalence | representative valid coefficients return the same `-A/B` potential as the former direct calculation within floating-point tolerance |

The existing 12-configuration functional matrix includes `model.options.FOPS-D34.json`, which enables explicit graph transport with `useCTRAM=true`. The focused boundary tests are numerical verification, not biological validation, and are executed by the existing basic-unit-test job through `TestRunner.runTests`.

Run these commands from the repository root unless noted otherwise.

### Which script to use

Use the script that matches the runtime path you actually want to test.

| Script | Purpose | Runtime path | Default project entry |
| --- | --- | --- | --- |
| `tests/validation/run_like_github_actions.sh` | Best local match for GitHub Actions validation | Apptainer | `Scripts/project.gs` |
| `tests/validation/run_multiple_scenarios.sh` | Run several CI-equivalent scenarios locally | Apptainer | `Scripts/project.gs` |
| `tests/validation/check_dai_2012_12L_and_3L.sh` | Convenience wrapper for the two DAI scenarios | Apptainer | `Scripts/project.gs` |
| `tests/gsz_test/run_archive_test.sh` | Structural plus functional archive validation | Direct Java by default; optional Apptainer | `Scripts/Scripts.gsz` |
| `tests/gsz_test/validate_gsz_structure.sh` | ZIP integrity, layout, metadata, manifest, and extracted-content validation | Shell/Python standard library | `Scripts/Scripts.gsz` |
| `tests/gsz_test/finalise_repository.sh` | Ordered source, package, archive, documentation, and final regression workflow | Direct Java plus local Apptainer acceptance | source and archive |
| `tests/validation/run_groimp_tests.sh` | Canonical low-level Apptainer runner | Apptainer | `Scripts/project.gs` |
| `tests/smoke_test/unitTest.sh` | Portable direct-Java smoke test | Java directly | `Scripts/project.gs` by default |
| `tests/diagnosis/check_output_dto_schema.py` | Static plant and hydraulic-debug DTO index/schema check | Python standard library | not applicable |

### 1. CI-equivalent local validation

This is the standard local validation path when you want to match GitHub Actions as closely as possible.

- Internally runs:

```bash
bash tests/validation/run_groimp_tests.sh XrunValidationTests <scenario>
```

- Uses Apptainer.
- Uses `Scripts/project.gs`.
- Temporarily patches `shouldContinue=false` during the run and restores it on exit.
- Greps the log for JUnit and validation failures, matching GitHub Actions behavior.

Commands:

```bash
bash tests/validation/run_like_github_actions.sh stormTest
bash tests/validation/run_like_github_actions.sh default
bash tests/validation/run_like_github_actions.sh antony-2010 120
```

The default scenario is `stormTest` if you omit the argument:

```bash
bash tests/validation/run_like_github_actions.sh
```

### 2. Multi-scenario local validation

This runs several scenarios through the same CI-equivalent path as `run_like_github_actions.sh`.

Default scenario matrix:

```text
default
antony-2010
dai-2012-12L
dai-2012-3L
FOPS-satDryTest
stormTest
```

Commands:

```bash
bash tests/validation/run_multiple_scenarios.sh
bash tests/validation/run_multiple_scenarios.sh default antony-2010
bash tests/validation/run_multiple_scenarios.sh default antony-2010 48
MAX_JOBS=1 bash tests/validation/run_multiple_scenarios.sh default antony-2010
MAX_JOBS=1 bash tests/validation/run_multiple_scenarios.sh default antony-2010 48
```

Notes:

- If the last argument is numeric, it is treated as `num_steps`.
- `MAX_JOBS` controls concurrency. Default is `2`.
- Each scenario writes both a wrapper log and a GroIMP log.

### 3. DAI helper

This helper is specifically for the two DAI scenarios and requires an explicit `--run`.

Commands:

```bash
bash tests/validation/check_dai_2012_12L_and_3L.sh --run
bash tests/validation/check_dai_2012_12L_and_3L.sh --run 48
```

What it does:

- Runs `dai-2012-12L` and `dai-2012-3L`
- Uses `run_multiple_scenarios.sh`
- Forces `MAX_JOBS=1`
- Applies a timeout guard

### 4. Packaged-project validation

These commands are maintained under `tests/gsz_test/`; they are listed here
because archive validation commonly follows source scenario validation.

Build only after source validation has passed. The canonical packager performs
a clean full rebuild; legacy `0` or `1` arguments no longer select an
incremental update:

```bash
bash bash_scripts/zip_groimp.sh
```

It stages the intended `Scripts/` files in a temporary directory, uses a
sorted manifest and fixed ZIP metadata, validates the temporary archive, and
atomically replaces `Scripts/Scripts.gsz` only on success.

The canonical package source is deliberately split:

- ordinary model sources, resources, and assets come from the working tree;
- GroIMP-managed `project.gs`, `graph*.xml`, `META-INF/MANIFEST.MF`, and
  `workbench.options` come from committed `HEAD` by default.

This prevents either unstaged or staged-but-uncommitted GroIMP saves,
including regenerated node IDs, from changing `Scripts.gsz` and then failing
when GitHub rebuilds it from a clean checkout. Packaging never reads these
files from the Git index.

For an intentional GroIMP project-file update, explicitly select the working
tree:

```bash
bash bash_scripts/zip_groimp.sh --metadata-source=worktree
bash tests/gsz_test/validate_gsz_structure.sh --metadata-source=worktree
```

Commit the changed project files and tested archive together. The validator
compares extracted contents against the selected canonical package-source
view and does not expect fixed GroIMP node IDs or a hard-coded checksum.

Run the independent structural validator at any time:

```bash
bash tests/gsz_test/validate_gsz_structure.sh
```

The structural check runs ZIP integrity and entry-list checks, rejects
duplicates and unsafe/root-prefixed paths, checks required GroIMP files,
extracts the archive, and compares both the normalized manifest and every
file's contents with the canonical package-source set.

The functional archive smoke test defaults to the direct-Java GroIMP runner:

```bash
bash tests/gsz_test/run_archive_test.sh default
bash tests/gsz_test/run_archive_test.sh stormTest
```

Use the maintained Apptainer runner explicitly when needed:

```bash
ARCHIVE_RUNNER=apptainer bash tests/gsz_test/run_archive_test.sh default
```

Check unchanged builds for byte-for-byte reproducibility:

```bash
bash tests/gsz_test/check_gsz_reproducibility.sh
```

The default `SOURCE_DATE_EPOCH` is `315532800` (1980-01-01 00:00:00 UTC).
Entries use fixed permissions, no extra ZIP metadata, stable ordering, and
the `stored` method. Avoiding compressor-version differences makes unchanged
builds byte-identical across the supported Python ZIP implementations.
The checksum is compared only between fresh builds and against the committed
archive bytes; CI does not store a fixed expected SHA-256 value.

#### Archive include and exclude policy

The archive includes every regular project file under `Scripts/` except the
explicit exclusions below. This includes `META-INF/MANIFEST.MF`, `project.gs`,
`graph.xml`, `workbench.options`, all source modules, Java helpers, text
resources, and project images. Files are stored at the archive root; there is
no outer `Scripts/` directory. The GroIMP project files named above use their
committed `HEAD` contents by default; local copies are used only in explicit
worktree mode.

Excluded content:

- `Scripts.gsz`, other nested `.gsz`/`.zip` files, and packaging workspaces;
- repository-only `.gitignore`, `.gitattributes`, and `AGENTS.md`;
- editor backups, swap files, logs, temporary files, and `.nfs*` files;
- compiled Python/Java files and cache directories;
- local GroIMP `config.properties.txt`;
- symlinks, which cause packaging to fail instead of being followed.

#### Ordered final pre-commit validation

Run this immediately before the intentional final commit:

```bash
bash tests/gsz_test/finalise_repository.sh
```

It runs the portable source smoke test and default local acceptance scenario
before packaging, checks two deterministic builds, performs structural and
functional archive validation, runs packaging-documentation consistency
checks, detects any later change inside `Scripts/`, and repeats the final
archive and documentation checks. It prints `git status --short` for review
and never creates a commit.

Hosted environments without the local Apptainer acceptance path may opt out
explicitly while retaining all portable stages:

```bash
FINALISE_SKIP_LOCAL_ACCEPTANCE=1 bash tests/gsz_test/finalise_repository.sh
```

For an intentional GroIMP project-file update, use:

```bash
bash tests/gsz_test/finalise_repository.sh --metadata-source=worktree
```

The negative atomic-replacement regression is:

```bash
bash tests/gsz_test/test_gsz_packaging_failures.sh
```

It deliberately corrupts only the temporary candidate and proves that the
validated committed archive is not replaced.

The project-file source-policy regression is:

```bash
bash tests/gsz_test/test_gsz_metadata_source.sh
```

It proves that normal packaging ignores local and Git-index metadata state,
explicit worktree mode includes intentional project metadata, and a missing
required worktree project file cannot replace the valid archive.

The canonical project files and archive are tracked and are not listed in
`.gitignore`. Some older local clones still have clone-local
`assume-unchanged` or `skip-worktree` flags. The finalization summary detects
hidden differences by comparing each worktree file directly with `HEAD`.

After intentional worktree-mode validation, prepare the complete tracked set:

```bash
bash bash_scripts/commit_project_files.sh
```

The helper clears local hide flags and stages `project.gs`, `graph*.xml`,
`META-INF/MANIFEST.MF`, `workbench.options`, and `Scripts.gsz`; it never
creates a commit. In normal HEAD mode, incidental local GroIMP regenerations
remain visible for review but are ignored by packaging.

### 5. Canonical Apptainer runner

`run_groimp_tests.sh` is the low-level runner used by the higher-level helpers.

Default behavior:

- Uses Apptainer
- Defaults to `Scripts/project.gs`
- Accepts optional overrides for steps and model-options file name

Commands:

```bash
bash tests/validation/run_groimp_tests.sh XrunValidationTests default
bash tests/validation/run_groimp_tests.sh XrunValidationTests stormTest 48
bash tests/validation/run_groimp_tests.sh XrunValidationTests antony-2010 120 model.options.ANTONY.2010.json
```

To force archive execution through the same runner:

```bash
PROJECT_ENTRY_HOST="$PWD/Scripts/Scripts.gsz" \
bash tests/validation/run_groimp_tests.sh XrunValidationTests default
```

To inspect its built-in help:

```bash
bash tests/validation/run_groimp_tests.sh --help
```

### 6. Portable smoke test

The portable runner is maintained under `tests/smoke_test/`. `unitTest.sh` is
useful as a lightweight smoke test when you do not want the Apptainer path.

Important:

- This is **not** equivalent to GitHub Actions validation.
- It runs GroIMP `core.jar` directly.
- It still defaults `MODEL_OPTIONS` to `model.options.default.json` unless you override it.

Commands:

```bash
bash tests/smoke_test/unitTest.sh
bash tests/smoke_test/unitTest.sh XrunTests default 48
bash tests/smoke_test/unitTest.sh XrunTests default 24 model.options.default.json
MODEL_OPTIONS=model.options.default.json bash tests/smoke_test/unitTest.sh XrunTests default 24
bash tests/smoke_test/unitTest.sh Xrun light-direct-meteo 25 model.options.photosynthesisTest.json
ARCHIVE_TEST=1 bash tests/smoke_test/unitTest.sh
```

The `light-direct-meteo` scenario exercises the asset-free leaf gas-exchange
branch of `directInput` using the normal climate input. Generic `directInput`
remains file-backed.

To inspect its built-in help:

```bash
bash tests/smoke_test/unitTest.sh --help
```

### 7. Diagnostic helpers

These focused checks are maintained under `tests/diagnosis/`.

To scan a GroIMP or unit-test log for semantic compile errors only:

```bash
bash tests/diagnosis/grep_compile_errors.sh
bash tests/diagnosis/grep_compile_errors.sh /tmp/fruitcropxl_check_compile_fixed.log
```

To check the output DTO contract without starting GroIMP:

```bash
python3 tests/diagnosis/check_output_dto_schema.py
```

This check requires declaration-ordered, contiguous `PlantLevelOutputData`
indices `0..159` and hydraulic-debug indices `0..20`. It also guards the
perennial-carbon block, the canopy-zone order from `intWaterPotential_1`
through `sugarConcentration_4`, and the separation of solver-only fields from
the standard plant table. The same check covers the debug option's default,
guarded loader, conditional writer and metadata initialization, fixed
filenames, and run-settings snapshot entry.

### Logs and outputs

Common log locations:

- `Model_output/logs/groimp_<scenario>.log`
  - written by `run_like_github_actions.sh`
- `Model_output/logs/groimp_archive_<scenario>.log`
  - written by `run_archive_test.sh`
- `tests/validation/<scenario>.log`
  - wrapper log written by `run_multiple_scenarios.sh`

Examples:

```bash
tail -n 50 Model_output/logs/groimp_stormTest.log
tail -n 50 Model_output/logs/groimp_archive_default.log
tail -n 50 tests/validation/default.log
```

### Expected output

After the simulation has been run, a list of values for the synthetic and validation fields relevant to the validation test will be output, accompanied by a condition determining the outcome of the test.

For example, the output shows that X passes the discrepancy and RMSE test by having values less than the defined threshold. This threshold is specified in the params.yaml configuration file.

Note: ellipses have been added to represent truncated outputs in this example.

```log
============== RMSE ==============
Synthetic values: leafWaterPotential(MPa)
  [-0.03999999910593033, -0.03999999910593033, -0.03999999910593033, ..., -1.7769473791122437]

Validation values: leaf.wp
  [0.0, 0.0, 0.0, ..., 0.0]
- RMSE: 1.2558640513832517 (1.3)

============== Discrepancy ==============
Synthetic values: leafWaterPotential(MPa)
  [-0.03999999910593033, -0.03999999910593033, -0.03999999910593033, ..., -1.7769473791122437]

Validation values: leafWaterPotential(MPa)
  [-0.03999999910593033, -0.03999999910593033, -0.03999999910593033, ..., -1.7769883871078491]
- Discrepancy: 1.6393865365492275E-4 (<= 0.05)?

============== RMSE ==============
Synthetic values: waterFlux(mg/plant/s)
  [0.4076437630988376, 0.40764654466842803, 0.40764673535673196, ..., 0.40764673535673196]

Validation values: E_mg.plant.s
  [0.165078493, 0.09211563, 0.3027064, ..., 0.165930569]
- RMSE: 2.053143673395151 (5.0)

============== Discrepancy ==============
Synthetic values: waterFlux(mg/plant/s)
  [0.4076437630988376, 0.40764654466842803, 0.40764673535673196, ..., 0.40764673535673196]

Validation values: waterFlux(mg/plant/s)
  [0.4076437630988376, 0.3964314509589556, 0.38872212958600555, ..., 0.40764673535673196]
- Discrepancy: 4.015892428474363E-4 (<= 0.05)?
Finished. Result: Failures: 0. Ignored: 0. Tests run: 4. Time: 41899ms.
```

## Configuration

Each validation test has two configuration files:

- `params.yaml` - parameters for each validation test
- `scenario.yaml` - parameters specific to running the given scenario

### `params.yaml` - Test parameter configuration

TODO: Consider renaming this yaml file; add more description for each yaml configuration field

The test parameter configuration is used to specify the validation dataset, relevant column names for fields of interest and threshold values.

Each type of test uses a specific format for its configuration (see [Adding tests for scenarios](#adding-tests-for-scenarios))

### `scenario.yaml` - Scenario configuration

- `file-name-model-options` - JSON file name of the scenario under test, e.g.: model.options.ANTONY.2010.json
- `max-steps` - number of steps to run the simulation
- `light-interception-mode` - optional explicit backend (`cpu`, `gpu`, `empiricalRegression`, `surrogateModel`, or `directInput`)
- `use-shading-factor` - optional shading-factor override, independent of backend selection

Use `light-interception-mode: cpu` for portable ray-tracing validation. Validation and low-core guards apply only to `gpu`; they must not silently replace an explicitly selected empirical, surrogate, or direct-input test mode. Empirical and surrogate tests must provide compatible deterministic assets and declare their supported resolution and organ types. The leaf gas-exchange test branch of `directInput` needs no separate light asset: it uses the scenario's meteorological `globalRadiation` multiplied once by environmental `fPAR` and does not invoke CPU/GPU ray tracing. Generic `directInput` remains file-backed. Python `.pkl` artifacts are not executable by the Java/GroIMP runtime. The deprecated `use-flux-light-model` YAML key remains accepted for compatibility (`false` maps to `cpu`, `true` to `gpu`) but should appear only in migration tests.

## Adding tests for scenarios

Suppose we want to create the validation test for the Antony-2010 scenario (model.options.Antony.2010.json).

Create a new directory under the configuration files

```sh
cd tests/validation
mkdir fops
cd fops
```

Create the two configuration files required by the validation test.

```sh
touch param.yaml
touch scenario.yaml
```

Write the following contents into the params.yaml file:

```yaml
discrepancy:
  dataset: ANTONY_2010_0_plant_level.csv
  threshold: 0.05

rmse:
  dataset: Exp_2010_Antony.obs.drying.cycle.csv
  synthetic-columns:
    - name: leafWaterPotential(MPa)
      rmse: 1.3 # 1.2567149081232705
    - name: waterFlux(mg/plant/s)
      rmse: 5 # 4.891102681935564
```

Similarly, write the following contents into the scenario.yaml file:

```yaml
file-name-model-options: model.options.ANTONY.2010.json
max-steps: 120
light-interception-mode: cpu
```

Copy the referenced validation datasets into the tests/validation/antony-2010 directory.

- `ANTONY_2010_0_plant_level.csv` - simulation output from the master branch to compare the output of the current branch
- `Exp_2010_Antony.obs.drying.cycle.csv` - experimental data for RMSE test

The directory now should have the following contents:

- ANTONY_2010_0_plant_level.csv
- Exp_2010_Antony.obs.drying.cycle.csv
- param.yaml
- scenario.yaml

Next, we need to define the testing logic in validationTests.rgg by creating a new test class that extends from `ValidationTestBase`

```java
// validationTests.rgg

/**
 * Validation testing class for ANTONY 2010.
 */
public class Antony2010ValidationUnitTest extends ValidationTestBase {

  @BeforeClass
  public static void setupAll() {
    validationDir = "antony-2010";
    init();
  }

  ...
}
```

Suppose we wish to conduct an RMSE test between the synthetic leaf water potential which is output with the column name of `leafWaterPotential(MPa)`, and the corresponding validation column `leaf.wp`.

This can be implemented by creating a new JUnit test and asserting whether the two columns indeed have less or equal RMSE.

```java
@Test
public void leafWaterRMSETest() {
  assertTrue(
    rmseTestMethods.hasLessOrEqualRMSE(
      "leafWaterPotential(MPa)",
      "leaf.wp"
    )
  );
}
```

Suppose we also want to conduct a discrepancy test for the output for leaf water potential between the current branch and the saved simulation output from master (`ANTONY_2010_0_plant_level.csv`).

Note: since the column name for leaf water potential in both synthetic and validation output tables are the same, we only need to provide the column name once.

```java
@Test
public void leafWaterPotentialDifferenceTest() {
  assertTrue(
    discrepancyTestMethods.withinDiscrepancyThreshold(
      "leafWaterPotential(MPa)"
    )
  );
}
```

The implementation of the test class should now look like this:

```java
/**
 * Validation testing class for ANTONY 2010.
 */
public class Antony2010ValidationUnitTest extends ValidationTestBase {

  @BeforeClass
  public static void setupAll() {
    validationDir = "antony-2010";
    init();
  }

  @Test
  public void leafWaterRMSETest() {
    assertTrue(
      rmseTestMethods.hasLessOrEqualRMSE(
        "leafWaterPotential(MPa)",
        "leaf.wp"
      )
    );
  }

  @Test
  public void leafWaterPotentialDifferenceTest() {
    assertTrue(
      discrepancyTestMethods.withinDiscrepancyThreshold(
        "leafWaterPotential(MPa)"
      )
    );
  }
}
```

Add the `antony-2010` scenario to the `getTestScenarios()` method in validation.rgg by including its test class `Antony2010ValidationUnitTest.clas` in the scenario map. This is done such that the test directory for Antony 2010 is recognised.

```java
// validation.rgg

protected static Map getTestScenarios() {
  Map scenarioMap = new HashMap();

  ...

  scenarioMap.put("antony-2010", Antony2010ValidationUnitTest.class); // Add this to the map

  ...

  return scenarioMap;
 }
```

We can now run the validation test for Antony 2010 by executing:

```bash
bash tests/validation/run_like_github_actions.sh antony-2010
```
