# Rebuilding the development image

How to get the same image as the one this project is developed in. Last checked: 2026-11-23, by rebuilding a fresh image with these commands (the project was loaded from the local checkout, before its first push).

## Versions

| What | Version |
|---|---|
| Pharo | the **latest** Pharo 15 build (development version), with its VM |
| Pharo MCP | [Evref-BL/MCP](https://github.com/Evref-BL/MCP), commit `8d9fcc571f1fda19ba5556960db55efd54fb6cc0` |
| This project | `BaselineOfCalypsoOnSteroids` in `src/` |

We use the latest Pharo 15 on purpose (decided with you on 2026-11-23), like CI, so that changes in Calypso and Spec show up early. If Pharo 15 changes too much, we pin a build here and in CI. The image is rebuilt every week and whenever an upstream PR we need is merged. On 2026-11-23 the latest build was 145 (`4743e62`).

## Steps

In an empty folder:

```bash
curl -L https://get.pharo.org/64/150+vm | bash
```

```bash
./pharo Pharo.image save calypso-on-steroids
```

```bash
./pharo calypso-on-steroids.image metacello install github://Evref-BL/MCP:8d9fcc571f1fda19ba5556960db55efd54fb6cc0/src MCP
```

```bash
./pharo calypso-on-steroids.image metacello install --strict --groups dev github://jordanmontt/calypso-on-steroids:main/src CalypsoOnSteroids
```

The `dev` group adds the development tools (`CalypsoOnSteroids-Inventory`), which never ship.

Then open the image with `./pharo-ui calypso-on-steroids.image`, evaluate `MCP startOnPort: 4001` in a Playground, and save the image. The agent connects to `http://localhost:4001/`.

To work on the code, the repository must be a Git checkout registered in Iceberg (Iceberg ▸ Add ▸ Clone from github.com), so that changes can be committed from the image.

## Check that the image is right

- The repository `calypso-on-steroids` shows no changes in Iceberg.
- Calypso's own tests are green: run the test packages matching `Calypso-.*Tests.*` (the same set as CI). On 2026-11-16, the 159 UI-level tests passed (1 skipped), see the [inventory](features/README.md#existing-tests-baseline-2026-11-16).
