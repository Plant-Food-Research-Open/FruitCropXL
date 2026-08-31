# Third-party software notices

FruitCropXL uses or interfaces with third-party software. Copyright in these components remains with their respective copyright holders, and those components remain subject to their own licence terms.


## GroIMP

- Component: GroIMP — Growth-grammar related Interactive Modelling Platform
- Upstream: <https://gitlab.com/grogra/groimp>
- Licence: GNU General Public License version 3 only (`GPL-3.0-only`)
- Version: selected by the separately distributed runtime or container image; the current download script does not pin an immutable GroIMP version
- Redistribution in the public Git payload: no

FruitCropXL source imports GroIMP, XL, RGG, GPUFlux, graph, geometry, and workbench APIs. GroIMP and its plugins retain their original copyright and licence notices.

## Apache Commons Math

- Component: Apache Commons Math
- Version referenced by the maintained runtime library set: 3.6.1
- Upstream: <https://commons.apache.org/proper/commons-math/>
- Copyright: The Apache Software Foundation and contributors
- Licence: Apache License 2.0 (`Apache-2.0`)
- Redistribution in the public Git payload: no standalone JAR, included in the GroIMP Apptainer image

FruitCropXL source imports Commons Math APIs. If the Commons Math binary is redistributed in a future release, its original `META-INF/LICENSE.txt` and `META-INF/NOTICE.txt` must be retained.

## Virtual Fruit / JFruit2

- Component: JFruit2, used by the FruitCropXL virtual-fruit integration
- Artifact examined in the source repository: `jfruit2-1.3.6-with-dependencies.R1.jar`
- Namespace: `org.inra.psh.jfruit2`
- Redistribution in the public Git payload: no standalone JAR, included in the GroIMP Apptainer image
- Licence for JFruit2 itself: GNU General Public License version 3 only (`GPL-3.0-only`)


## Other runtime libraries

FruitCropXL also imports APIs supplied by the configured GroIMP/runtime installation, including Jackson, Apache Commons CLI and Configuration, a solar-positioning library, JUnit, and FruitCropXL configuration/output helper libraries. 

The separately downloaded GroIMP Apptainer image contains its own runtime dependency set. Its publisher must retain the licence and NOTICE material required by every component in that image. Publishing the image is a separate compliance scope from publishing this Git repository.

## Redistribution rule

Before adding any third-party JAR, native library, or container image to the public payload:

1. record the exact artifact name and version;
2. identify its upstream project and copyright holder;
3. verify its SPDX licence identifier and compatibility with the distribution;
4. retain every original `LICENSE`, `NOTICE`, and attribution file;
5. document whether it is bundled or downloaded separately; and
6. obtain legal review for unresolved, custom, or missing licence terms.

The exporter audits any future public JAR for embedded or adjacent licence material. Passing that mechanical check does not replace legal review or the component-specific entry required here.
