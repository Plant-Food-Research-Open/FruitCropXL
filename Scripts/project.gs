<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<project xmlns="http://grogra.de/registry" graph="graph.xml">
 <import plugin="de.grogra.imp3d" version="2.2.1"/>
 <import plugin="de.grogra.coolbar" version="0.6"/>
 <import plugin="de.grogra.rgg" version="2.2.1"/>
 <import plugin="de.grogra.imp" version="2.2.1"/>
 <import plugin="de.grogra.math" version="2.2.1"/>
 <import plugin="de.grogra" version="2.2.1"/>
 <import plugin="de.grogra.ray" version="2.2.1"/>
 <import plugin="de.grogra.pf" version="2.2.1"/>
 <registry>
  <ref name="project">
   <ref name="objects">
    <ref name="files">
     <de.grogra.pf.ui.registry.SourceDirectory name="main" systemId="pfs:main">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="main.rgg" systemId="pfs:main/main.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/plain" name="readme.txt" systemId="pfs:main/readme.txt"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="charts.rgg" systemId="pfs:main/charts.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="outputTables.rgg" systemId="pfs:main/outputTables.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="diagnosticTables.rgg" systemId="pfs:main/diagnosticTables.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesBase.rgg" systemId="pfs:main/updatesBase.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="developBase.rgg" systemId="pfs:main/developBase.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/plain" name="tricks.txt" systemId="pfs:main/tricks.txt"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="config" systemId="pfs:config">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="globalParameters.rgg" systemId="pfs:config/globalParameters.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="plantParameters.rgg" systemId="pfs:config/plantParameters.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="simRunBase.rgg" systemId="pfs:config/simRunBase.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationBase.rgg" systemId="pfs:config/initiationBase.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initialConditions.rgg" systemId="pfs:config/initialConditions.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="modelOptions.rgg" systemId="pfs:config/modelOptions.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="organs" systemId="pfs:organs">
      <de.grogra.pf.ui.registry.SourceDirectory name="baseModules" systemId="pfs:organs/baseModules">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="plantBase.rgg" systemId="pfs:organs/baseModules/plantBase.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="shootBase.rgg" systemId="pfs:organs/baseModules/shootBase.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="fieldBase.rgg" systemId="pfs:organs/baseModules/fieldBase.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="absOrgans" systemId="pfs:organs/absOrgans">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="interfaces.rgg" systemId="pfs:organs/absOrgans/interfaces.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budBase.rgg" systemId="pfs:organs/absOrgans/budBase.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="flowerBase.rgg" systemId="pfs:organs/absOrgans/flowerBase.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="fruitBase.rgg" systemId="pfs:organs/absOrgans/fruitBase.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="absOrgan.rgg" systemId="pfs:organs/absOrgans/absOrgan.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="rootSystem" systemId="pfs:organs/rootSystem">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="rootSystem.rgg" systemId="pfs:organs/rootSystem/rootSystem.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="fineRoot.rgg" systemId="pfs:organs/rootSystem/fineRoot.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="structuralRoot.rgg" systemId="pfs:organs/rootSystem/structuralRoot.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="leaf.rgg" systemId="pfs:organs/leaf.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="shoot.rgg" systemId="pfs:organs/shoot.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="canopy.rgg" systemId="pfs:organs/canopy.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="dataModels" systemId="pfs:dataModels">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="FieldLevelOutputData.java" systemId="pfs:dataModels/FieldLevelOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="MeanFruitOutputData.java" systemId="pfs:dataModels/MeanFruitOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="PlantLevelOutputData.java" systemId="pfs:dataModels/PlantLevelOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="WaterFluxSolverOutputData.java" systemId="pfs:dataModels/WaterFluxSolverOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="LeafExpansionDiagnosticOutputData.java" systemId="pfs:dataModels/LeafExpansionDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="ActualLeafSummaryDiagnosticOutputData.java" systemId="pfs:dataModels/ActualLeafSummaryDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="CarbonTransportMassBalanceDiagnosticOutputData.java" systemId="pfs:dataModels/CarbonTransportMassBalanceDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="AppleFlowerTimingDiagnosticOutputData.java" systemId="pfs:dataModels/AppleFlowerTimingDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="AppleSpurBourseDiagnosticOutputData.java" systemId="pfs:dataModels/AppleSpurBourseDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="AppleFlowerToFruitDiagnosticOutputData.java" systemId="pfs:dataModels/AppleFlowerToFruitDiagnosticOutputData.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="AppleLeafAxisDiagnosticOutputData.java" systemId="pfs:dataModels/AppleLeafAxisDiagnosticOutputData.java"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="environment" systemId="pfs:environment">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="soil.rgg" systemId="pfs:environment/soil.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="environment.rgg" systemId="pfs:environment/environment.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="physioFunctions" systemId="pfs:physioFunctions">
      <de.grogra.pf.ui.registry.SourceDirectory name="lightInterception" systemId="pfs:physioFunctions/lightInterception">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="lightInterception.rgg" systemId="pfs:physioFunctions/lightInterception/lightInterception.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="LightInterceptionResult.java" systemId="pfs:physioFunctions/lightInterception/LightInterceptionResult.java"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="photosynthesisAndTranspiration.rgg" systemId="pfs:physioFunctions/photosynthesisAndTranspiration.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="plantHydraulics.rgg" systemId="pfs:physioFunctions/plantHydraulics.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="carbonAllocation.rgg" systemId="pfs:physioFunctions/carbonAllocation.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="carbonTransport.rgg" systemId="pfs:physioFunctions/carbonTransport.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="phenology.rgg" systemId="pfs:physioFunctions/phenology.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="leafAngleOptimization.rgg" systemId="pfs:physioFunctions/leafAngleOptimization.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="structuralVariation.rgg" systemId="pfs:physioFunctions/structuralVariation.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="management" systemId="pfs:management">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pruning.rgg" systemId="pfs:management/pruning.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="shootPositioning.rgg" systemId="pfs:management/shootPositioning.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="twinningPlanner.rgg" systemId="pfs:management/twinningPlanner.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budPlanner.rgg" systemId="pfs:management/budPlanner.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budPlannerConfig.rgg" systemId="pfs:management/budPlannerConfig.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budPlannerT0.rgg" systemId="pfs:management/budPlannerT0.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budPlannerT1.rgg" systemId="pfs:management/budPlannerT1.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budReflectionUtils.rgg" systemId="pfs:management/budReflectionUtils.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="leafPlanner.rgg" systemId="pfs:management/leafPlanner.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="fruitPlanner.rgg" systemId="pfs:management/fruitPlanner.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="alterModules" systemId="pfs:alterModules">
      <de.grogra.pf.ui.registry.SourceDirectory name="updates" systemId="pfs:alterModules/updates">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesApple.rgg" systemId="pfs:alterModules/updates/updatesApple.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesSingleRoot.rgg" systemId="pfs:alterModules/updates/updatesSingleRoot.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesGrapevine.rgg" systemId="pfs:alterModules/updates/updatesGrapevine.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesBerryPopulation.rgg" systemId="pfs:alterModules/updates/updatesBerryPopulation.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="updatesVirtualFruit.rgg" systemId="pfs:alterModules/updates/updatesVirtualFruit.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="simRun" systemId="pfs:alterModules/simRun">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="simRunStandard.rgg" systemId="pfs:alterModules/simRun/simRunStandard.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="simRunBerryPopulation.rgg" systemId="pfs:alterModules/simRun/simRunBerryPopulation.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="simRunOptimalCanopyArchitecture.rgg" systemId="pfs:alterModules/simRun/simRunOptimalCanopyArchitecture.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="simRunIdealVine.rgg" systemId="pfs:alterModules/simRun/simRunIdealVine.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="initiation" systemId="pfs:alterModules/initiation">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationVirtualFruit.rgg" systemId="pfs:alterModules/initiation/initiationVirtualFruit.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationSingleRoot.rgg" systemId="pfs:alterModules/initiation/initiationSingleRoot.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationSingleLeaf.rgg" systemId="pfs:alterModules/initiation/initiationSingleLeaf.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationBerryPopulation.rgg" systemId="pfs:alterModules/initiation/initiationBerryPopulation.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationStructuralVariation.rgg" systemId="pfs:alterModules/initiation/initiationStructuralVariation.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationOptimalCanopyArchitecture.rgg" systemId="pfs:alterModules/initiation/initiationOptimalCanopyArchitecture.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationStandard.rgg" systemId="pfs:alterModules/initiation/initiationStandard.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationArchReader.rgg" systemId="pfs:alterModules/initiation/initiationArchReader.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationArchReaderGPU.rgg" systemId="pfs:alterModules/initiation/initiationArchReaderGPU.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationStandardGridClone.rgg" systemId="pfs:alterModules/initiation/initiationStandardGridClone.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="initiationFieldRandomCanopy.rgg" systemId="pfs:alterModules/initiation/initiationFieldRandomCanopy.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="develop" systemId="pfs:alterModules/develop">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="developApple.rgg" systemId="pfs:alterModules/develop/developApple.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="developGrapevine.rgg" systemId="pfs:alterModules/develop/developGrapevine.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="developGrapevineStructuralVariation.rgg" systemId="pfs:alterModules/develop/developGrapevineStructuralVariation.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="Flowers" systemId="pfs:alterModules/Flowers">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="flowerApple.rgg" systemId="pfs:alterModules/Flowers/flowerApple.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="buds" systemId="pfs:alterModules/buds">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budApple.rgg" systemId="pfs:alterModules/buds/budApple.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="budGrapevine.rgg" systemId="pfs:alterModules/buds/budGrapevine.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
      <de.grogra.pf.ui.registry.SourceDirectory name="fruit" systemId="pfs:alterModules/fruit">
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="virtualFruit.rgg" systemId="pfs:alterModules/fruit/virtualFruit.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="berryComplex.rgg" systemId="pfs:alterModules/fruit/berryComplex.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="berrySimple.rgg" systemId="pfs:alterModules/fruit/berrySimple.rgg"/>
       <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="berryYield.rgg" systemId="pfs:alterModules/fruit/berryYield.rgg"/>
      </de.grogra.pf.ui.registry.SourceDirectory>
     </de.grogra.pf.ui.registry.SourceDirectory>
     <de.grogra.pf.ui.registry.SourceDirectory name="utils" systemId="pfs:utils">
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="extraTools.rgg" systemId="pfs:utils/extraTools.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="dataset.rgg" systemId="pfs:utils/dataset.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="leafShape.rgg" systemId="pfs:utils/leafShape.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="server.rgg" systemId="pfs:utils/server.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="socketRun.rgg" systemId="pfs:utils/socketRun.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="tests.rgg" systemId="pfs:utils/tests.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="tasks.rgg" systemId="pfs:utils/tasks.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="validation.rgg" systemId="pfs:utils/validation.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="validationTests.rgg" systemId="pfs:utils/validationTests.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="RequestHandler.java" systemId="pfs:utils/RequestHandler.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="CacheManager.java" systemId="pfs:utils/CacheManager.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-java" name="BasicMinervaHelper.java" systemId="pfs:utils/BasicMinervaHelper.java"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="archReader.rgg" systemId="pfs:utils/archReader.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="aggregatedRoot.rgg" systemId="pfs:utils/aggregatedRoot.rgg"/>
      <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="fieldCanopyReader.rgg" systemId="pfs:utils/fieldCanopyReader.rgg"/>
     </de.grogra.pf.ui.registry.SourceDirectory>
    </ref>
    <ref name="datasets">
     <de.grogra.pf.registry.SharedValue name="CHART 1" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAABHcEAAAABHQABGZhYnN0AA9hYnNtMiB1bW9sL20yL3N0ABxpbmNvbWluZyByYWRpYXRpb24gdW1vbC9tMi9zdAAncGxhbnQgcmFkaWF0aW9uIGFic29ycHRpb24gdW1vbC9wbGFudC9zeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAPUmFkaWF0aW9uIChQIDEpcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 2" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAACncEAAAACnNyABNqYXZhLmxhbmcuQ2hhcmFjdGVyNItH2WsaJngCAAFDAAV2YWx1ZXhwAEFzcQB+AAgAQnNxAH4ACABDc3EAfgAIAERzcQB+AAgARXNxAH4ACABGc3EAfgAIAEdzcQB+AAgASHQAH0NhcmJvbkFzc2ltaWxhdGlvbiBbbWcvaC9wbGFudF10ABxjYXJib25Bc3NpbWlsYXRpb24gW21nL2gvbTJdeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAeQ2FyYm9uIGFzc2ltaWxhdGlvbiwgW21nL2hvdXJdcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 3" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAA3cEAAAAA3QAFHdhdGVyIGZsdXggb3B0aW1pemVkdAAUd2F0ZXIgZmx1eCBwb3RlbnRpYWx0ABNvYnNlcnZlZCB3YXRlciBmbHV4eHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAkV2F0ZXIgZmx1eCBvZiB0aGUgd2hvbGUgcGxhbnQgW21nL3NdcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 4" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAA3cEAAAAA3QAFVh5bGVtIHdhdGVyIHBvdGVudGlhbHEAfgAIdAAgRmluZVJvb3Qgc3VyZmFjZSB3YXRlciBwb3RlbnRpYWx4cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0ABtYeWxlbSB3YXRlciBwb3RlbnRpYWwgW01QYV1w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 5" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAHHcEAAAAHHQADEZyZXNoIHdlaWdodHQACkRyeSB3ZWlnaHR0AApmcnVpdCBhZ2VEdAALYWdlIGluIGhvdXJ0AAxGcnVpdCBudW1iZXJ0AB5mcnVpdC5zdWdhckNvbmNlbnRyYXRpb25fZnJ1aXR0ABJmcnVpdC5zb2x1YmxlU3VnYXJ0ABhmcnVpdC5zdWdhclVwdGFrZV9hY3RpdmV0ABlmcnVpdC5zdWdhclVwdGFrZV9wYXNzaXZldAAaZnJ1aXQuc3VnYXJVcHRha2VfbWFzc2Zsb3d0AB9mcnVpdC5zdWdhckNvbmNlbnRyYXRpb25fcGhsb2VtdAAYZnJ1aXQud2F0ZXJVcHRha2VfcGhsb2VtdAAaZnJ1aXQudHVyZ29yUHJlc3N1cmVfZnJ1aXR0AAhzY2VuYXJpb3QABGhvdXJ0AAJUYXQAAlJIdAAZcGhsb2VtQ2FyYm9uQ29uY2VudHJhdGlvbnQAFHdhdGVyUG90ZW50aWFsX3h5bGVtdAAXZnJ1aXQuc3RydWN0dXJhbEJpb21hc3N0AAltYWxpY0FjaWR0AAx0YXJ0YXJpY0FjaWR0ABhtYWxpY0NvbmNlbnRyYXRpb25fZnJ1aXR0ABt0YXJ0YXJpY0NvbmNlbnRyYXRpb25fZnJ1aXR0AAZMeHlsZW10AAdMcGhsb2VtdAAbb3Ntb3RpY1dhdGVyUG90ZW50aWFsX2ZydWl0dAARd2F0ZXJVcHRha2VfeHlsZW14cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0ACBGcnVpdCBmcmVzaCBhbmQgZHJ5IHdlaWdodCwgW21nXXA="/>
     <de.grogra.pf.registry.SharedValue name="CHART 6" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAA3cEAAAAA3QAF09zbWV0aWMgd2F0ZXIgcG90ZW50aWFsdAAPVHVyZ29yIHByZXNzdXJldAAPV2F0ZXIgcG90ZW50aWFseHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAdUGhsb2VtIHdhdGVyIHBvdGVudGlhbCwgW01QYV1w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 7" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAABXcEAAAABXQABUJlcnJ5dAAEUm9vdHQAEHdvb2QgKyBpbnRlcm5vZGV0AAxMZWFmIGxvYWRpbmd0ABZ3b29kK2ludGVybm9kZSBsb2FkaW5neHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAXQyBwYXJ0aXRpb25pbmcgZnJhY3Rpb25w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 8" type="de.grogra.pf.data.Dataset" value="serialized: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BHBzcQB+AFUAAAAAAAAAAHEAfgFAcQB+AUBzcQB+AFFxAH4ABHBzcQB+AFoAAAAAcQB+AUJxAH4BQnhzcQB+AAUAAAADdwQAAAADc3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4BRXEAfgFFc3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4BR3EAfgFHc3EAfgBRcQB+AARwc3EAfgBaAAAAAHEAfgFJcQB+AUl4c3EAfgAFAAAAA3cEAAAAA3NxAH4AUXEAfgAEcHNxAH4AVQAAAAAAAAAAcQB+AUxxAH4BTHNxAH4AUXEAfgAEcHNxAH4AVQAAAAAAAAAAcQB+AU5xAH4BTnNxAH4AUXEAfgAEcHNxAH4AWgAAAABxAH4BUHEAfgFQeHNxAH4ABQAAAAN3BAAAAANzcQB+AFFxAH4ABHBzcQB+AFUAAAAAAAAAAHEAfgFTcQB+AVNzcQB+AFFxAH4ABHBzcQB+AFUAAAAAAAAAAHEAfgFVcQB+AVVzcQB+AFFxAH4ABHBzcQB+AFoAAAAAcQB+AVdxAH4BV3hzcQB+AAUAAAADdwQAAAADc3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4BWnEAfgFac3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4BXHEAfgFcc3EAfgBRcQB+AARwc3EAfgBaAAAAAHEAfgFecQB+AV54c3EAfgAFAAAAA3cEAAAAA3NxAH4AUXEAfgAEcHNxAH4AVQAAAAAAAAAAcQB+AWFxAH4BYXNxAH4AUXEAfgAEcHNxAH4AVQAAAAAAAAAAcQB+AWNxAH4BY3NxAH4AUXEAfgAEcHNxAH4AWgAAAABxAH4BZXEAfgFleHNxAH4ABQAAAAN3BAAAAANzcQB+AFFxAH4ABHBzcQB+AFUAAAAAAAAAAHEAfgFocQB+AWhzcQB+AFFxAH4ABHBzcQB+AFUAAAAAAAAAAHEAfgFqcQB+AWpzcQB+AFFxAH4ABHBzcQB+AFoAAAAAcQB+AWxxAH4BbHhzcQB+AAUAAAADdwQAAAADc3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4Bb3EAfgFvc3EAfgBRcQB+AARwc3EAfgBVAAAAAAAAAABxAH4BcXEAfgFxc3EAfgBRcQB+AARwc3EAfgBaAAAAAHEAfgFz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"/>
     <de.grogra.pf.registry.SharedValue name="CHART 9" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAncEAAAAAnQAEFBsYW50IGJpb21hc3MoZyl0ABBDYXJib24gdG90YWwgKGcpeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAYUGxhbnQgZHJ5IG1hc3MgW2ddIChQIDUpcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 10" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAFXcEAAAAFXQABmxlYWZETXQAC2ludGVybm9kZURNdAAGd29vZERNdAAGcm9vdERNdAAHYmVycnlETXQAB2xlYWZOU0N0AAZpbnROU0N0AAd3b29kTlNDdAAHcm9vdE5TQ3QACmJlcnJ5U3VnYXJ0AA9zb3VyY2VMb2FkaW5nX2J0AA9TWU5USEVTSVNfSU5UREV0AA9TWU5USEVTSVNfUk9PVFN0AAhLTV9ST09UU3QACEtNX0JFUlJZdAARS01fUk9PVFNfUkVTRVJWRVN0AAxLTV9JTlRERV9TRUN0AAhLbGVha2FnZXQAA2RheXQACWhvdXJPZkRheXQACHNjZW5hcmlveHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAbYmlvbWFzcyBvZiBkaWZmZXJlbnQgb3JnYW5zcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 11" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAXcEAAAAAXQABUxyb290eHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAbUm9vdCBjb25kdWN0YW5jZSBbbWcvTVBhL3NdcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 12" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAA3cEAAAAA3QAFVh5bGVtIHdhdGVyIHBvdGVudGlhbHEAfgAIdAAcUm9vdCBzdXJmYWNlIHdhdGVyIHBvdGVudGlhbHhwc3EAfgAFAAAAAHcEAAAAAHhzcQB+AAUAAAAAdwQAAAAAeHQAG1h5bGVtIHdhdGVyIHBvdGVudGlhbCBbTVBhXXA="/>
     <de.grogra.pf.registry.SharedValue name="CHART 13" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAncEAAAAAnQAEUFCQSBjb25jZW50cmF0aW9udAAMT2JzZXJ2ZWQgQUJBeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAZQUJBIGNvbmNlbnRyYXRpb24gdW1vbC9tM3A="/>
     <de.grogra.pf.registry.SharedValue name="TABLE 1" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAG3cEAAAAG3QABHllYXJ0AAlkYXlPZlllYXJ0AAlob3VyT2ZEYXl0AAhsYXRpdHVkZXQACWxvbmdpdHVkZXQAC3Jvd0Rpc3RhbmNldAANcGxhbnREaXN0YW5jZXQADnJvd09yaWVudGF0aW9udAAIc2NlbmFyaW90AA1hZ2UtZGVncmVlRGF5dAAIYWdlLWRheXN0ABxpbmNvbWluZ1JhZGlhdGlvbih1bW9sL20yL3MpdAAHYXppbXV0aHQABnplbml0aHQADnNvbGFyRWxldmF0aW9udAAXbGVhZi1hcmVhLXBlci1wbGFudChtMil0AANMQUl0ABtob3VybHlBYnNvcmJlZFJhZGlhdGlvbihNSil0AARmYWJzdAABa3QAC2ZhYnNfZ3JvdW5kdAAIa19ncm91bmR0AAtmUEFSTG93LTEvM3QAC2ZQQVJNaWQtMi8zdAAGZlBBUlVwdAALZlBBUi1nbG9iYWx0AA1mRGlmZnVzZUxpZ2h0eHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAASRmllbGQtbGV2ZWwgb3V0cHV0cA=="/>
     <de.grogra.pf.registry.SharedValue name="TABLE 2" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAOHcEAAAAOHQABmRheShkKXQACWhvdXJPZkRheXQACHNjZW5hcmlvdAAHYWdlKGRkKXQACWFnZShkYXlzKXQAC1RhIChkZWdyZWUpdAACcmh0ABNiZXJyeU51bWJlclBlckJ1bmNodAATYnVuY2hOdW1iZXJQZXJQbGFudHQAGHh5bGVtV2F0ZXJQb3RlbnRpYWwoYmFyKXQAHnN1Z2FyQ29uY2VudHJhdGlvbl9waGxvZW0oZy9nKXQACHZlcmFpc29udAAPZnJlc2hXZWlnaHQobWcpdAANZHJ5V2VpZ2h0KG1nKXQAGnN1Z2FyQ29uY2VudHJhdGlvbihnL2doMjApdAAQc29sdWJsZVN1Z2FyKG1nKXQAEGNhcmJvbl90b3RhbChtZyl0AAx3YXRlckNvbnRlbnR0AA13YXRlck1hc3MobWcpdAAWdW5sb2FkaW5nUGVyRnJ1aXQobWdjKXQAE3VubG9hZGluZ0J1bmNoKG1nQyl0ACNzdW1CZXJyeVVubG9hZGluZ1N1Y3Jvc2UobWdTdWNyb3NlKXQAKXNpbmdsZUJlcnJ5QWN0aXZlU3Vjcm9zZXVwdGFrZShtZ1N1Y3Jvc2UpdAAec2luZ2xlUGFzc2l2ZVVwdGFrZShtZ1N1Y3Jvc2UpdAAZc2luZ2xlTWFzc0Zsb3cobWdTdWNyb3NlKXQAFW1haW50ZW5hbmNlQmVycnkobWdDKXQAFGdyb3d0aENvc3RCZXJyeShtZ0MpdAAUd2F0ZXJVcHRha2VfeHlsZW0oZyl0ABV3YXRlclVwdGFrZV9waGxvZW0oZyl0ABNyZXNwaXJhdGlvbldhdGVyKGcpdAAUdHJhbnNwaXJhdGlvbk1hc3MoZyl0AA1kZWx0YVdhdGVyKGcpdAAgb3Ntb3RpY1dhdGVyUG90ZW50aWFsX2ZydWl0KE1QYSl0ABl0dXJnb3JQcmVzc3VyZV9mcnVpdChNUGEpdAAZd2F0ZXJQb3RlbnRpYWxfZnJ1aXQoTVBhKXQAIW9zbW90aWNXYXRlclBvdGVudGlhbF9waGxvZW0oTVBhKXQAGnR1cmdvclByZXNzdXJlX3BobG9lbShNUGEpdAAad2F0ZXJQb3RlbnRpYWxfcGhsb2VtKE1QYSl0AAtBZnJ1aXQoY20yKXQAC0F4eWxlbShjbTIpdAAMQXBobG9lbShjbTIpdAATTHh5bGVtKGcgY20yL2Jhci9oKXQAFExwaGxvZW0oZyBjbTIvYmFyL2gpdAApb3Ntb3RpY1dhdGVyUG90ZW50aWFsX3BhcnRpYWxDb250cmlidXRpb250ACBjZWxsV2FsbEV4dGVuc2liaWxpdHkocGVyLmJhci5oKXQAE2VsYXN0aWNNb2R1bHVzKGJhcil0ABBidWxrTW9kdWx1cyhiYXIpdAA0c3VnYXJDb25jZW50cmF0aW9uTW9sZV9mcnVpdChtb2xzdWNyb3NlL21vbHNvbHV0aW9uKXQACnJvKGNtcGVyaCl0AA1tYWxpY0FjaWQobWcpdAAQdGFydGFyaWNBY2lkKG1nKXQAHW1hbGljQ29uY2VudHJhdGlvbl9mcnVpdChnL2cpdAAgdGFydGFyaWNDb25jZW50cmF0aW9uX2ZydWl0KGcvZyl0ACVtYWxpY0NvbmNlbnRyYXRpb25Nb2xlX2ZydWl0KG1vbC9tb2wpdAAodGFydGFyaWNDb25jZW50cmF0aW9uTW9sZV9mcnVpdChtb2wvbW9sKXQACHZvbChjbTMpeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAQRnJ1aXQgcHJvcGVydGllc3A="/>
     <de.grogra.pf.registry.SharedValue name="CHART 0" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAXcEAAAAAXQAEXNpbVJhdGUgKHN0ZXBzL3MpeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAXU2ltdWxhdGlvbiByYXRlKHMvc3RlcClw"/>
     <de.grogra.pf.registry.SharedValue name="CHART 14" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAXcEAAAAAXQAG1BobG9lbSBjYXJib24gY29uY2VudHJhdGlvbnhwc3EAfgAFAAAAAHcEAAAAAHhzcQB+AAUAAAAAdwQAAAAAeHQAH3BobG9lbSBjb25jZW50cmF0aW9uIFttZy9tZ0gyMF1w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 15" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAB3cEAAAAB3QAC2xlYWYgbG9kaW5ndAARaW50ZXJub2RlIGxvYWRpbmd0AAx3b29kIGxvYWRpbmd0ABFpbnRlcm5vZGUgbGVha2FnZXQADHdvb2QgbGVha2FnZXQADXJvb3QgdW5sb2Rpbmd0AA9iZXJyeSB1bmxvYWRpbmd4cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0ABBDYXJib24gcGFydGl0aW9ucA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 16" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAABXcEAAAABXQABUJlcnJ5dAAEUm9vdHQAEHdvb2QgKyBpbnRlcm5vZGV0AAxMZWFmIGxvYWRpbmd0ABZ3b29kK2ludGVybm9kZSBsb2FkaW5neHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAXQyBwYXJ0aXRpb25pbmcgZnJhY3Rpb25w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 17" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAAXcEAAAAAXQAGUJlcnJ5IHN1Z2FyIGNvbmNlbnRyYXRpb254cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHhxAH4ACHA="/>
     <de.grogra.pf.registry.SharedValue name="CHART 18" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAABXcEAAAABXQADEZyZXNoIHdlaWdodHQACkRyeSB3ZWlnaHR0AAtEYXkgb2YgeWVhcnQAC0hvdXIgb2YgZGF5dAAMQmVycnkgbnVtYmVyeHBzcQB+AAUAAAAAdwQAAAAAeHNxAH4ABQAAAAB3BAAAAAB4dAAgQmVycnkgZnJlc2ggYW5kIGRyeSB3ZWlnaHQsIFttZ11w"/>
     <de.grogra.pf.registry.SharedValue name="CHART 19" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAABHcEAAAABHQADFdhdGVyIHVwdGFrZXQAEXJlc3BpcmF0aW9uIHdhdGVydAASdHJhbnNwaXJhdGlvbiBsb3N0dAANd2F0ZXIgYmFsYW5jZXhwc3EAfgAFAAAAAHcEAAAAAHhzcQB+AAUAAAAAdwQAAAAAeHQAF1dhdGVyIGJhbGFuY2UsIFtnL2hvdXJdcA=="/>
     <de.grogra.pf.registry.SharedValue name="CHART 20" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAEXcEAAAAEXQAEmxlYWYgY29uZHVjdGFuY2UgMXQAEmxlYWYgY29uZHVjdGFuY2UgMnQAEmxlYWYgY29uZHVjdGFuY2UgM3QAEmxlYWYgY29uZHVjdGFuY2UgNHQAEmxlYWYgY29uZHVjdGFuY2UgNXQAEmxlYWYgY29uZHVjdGFuY2UgNnQAEmxlYWYgY29uZHVjdGFuY2UgN3QAEmxlYWYgY29uZHVjdGFuY2UgOHQAEmxlYWYgY29uZHVjdGFuY2UgOXQAE2xlYWYgY29uZHVjdGFuY2UgMTB0ABNsZWFmIGNvbmR1Y3RhbmNlIDExdAATbGVhZiBjb25kdWN0YW5jZSAxMnQAE2xlYWYgY29uZHVjdGFuY2UgMTN0ABNsZWFmIGNvbmR1Y3RhbmNlIDE0dAATbGVhZiBjb25kdWN0YW5jZSAxNXQAE2xlYWYgY29uZHVjdGFuY2UgMTZ0ABhsZWFmIGNvbmR1Y3RhbmNlIHRhcmRpZXV4cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0AC5MZWFmIGNvbmR1Y3RhbmNlIG9mIGxlYXZlcyAxIHRvIDE2LCBbbWcvTVBhL3NdcA=="/>
     <de.grogra.pf.registry.SharedValue name="TABLE 3" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAaXcEAAAAaXQACHNjZW5hcmlvdAAJc2NlbmFyaW8ydAAGZGF5KGQpdAAJaG91ck9mRGF5dAAIaW50MS5jcHR0AAhpbnQyLmNwdHQACGludDMuY3B0dAAIaW50NC5jcHR0AAhpbnQ1LmNwdHQACGludDYuY3B0dAAIaW50Ny5jcHR0AAhpbnQ4LmNwdHQACGludDkuY3B0dAAJaW50MTAuY3B0dAAJdHJ1bmsuY3B0dAAIcm9vdC5jcHR0AAZTMS5jcGJ0AAZTMi5jcGJ0AAZTMy5jcGJ0AAZTNC5jcGJ0AAZTNS5jcGJ0AAZTNi5jcGJ0AAZTNy5jcGJ0AAZTOC5jcGJ0AAZTOS5jcGJ0AAdTMTAuY3BidAAJdHJ1bmsuY3BidAAIcm9vdC5jcGJ0ABBpbnQxLmogKG1nL2hvdXIpdAAQaW50Mi5qIChtZy9ob3VyKXQAEGludDMuaiAobWcvaG91cil0ABBpbnQ0LmogKG1nL2hvdXIpdAAQaW50NS5qIChtZy9ob3VyKXQAEGludDYuaiAobWcvaG91cil0ABBpbnQ3LmogKG1nL2hvdXIpdAAQaW50OC5qIChtZy9ob3VyKXQAEGludDkuaiAobWcvaG91cil0ABFpbnQxMC5qIChtZy9ob3VyKXQAEXRydW5rLmogKG1nL2hvdXIpdAAQcm9vdC5qIChtZy9ob3VyKXQADWludDEuQ05TIChtZyl0AA1pbnQyLkNOUyAobWcpdAANaW50My5DTlMgKG1nKXQADWludDQuQ05TIChtZyl0AA1pbnQ1LkNOUyAobWcpdAANaW50Ni5DTlMgKG1nKXQADWludDcuQ05TIChtZyl0AA1pbnQ4LkNOUyAobWcpdAANaW50OS5DTlMgKG1nKXQADmludDEwLkNOUyAobWcpdAAOdHJ1bmsuQ05TIChtZyl0AA1yb290LkNOUyAobWcpdAAMaW50MS5DUyAobWcpdAAMaW50Mi5DUyAobWcpdAAMaW50My5DUyAobWcpdAAMaW50NC5DUyAobWcpdAAMaW50NS5DUyAobWcpdAAMaW50Ni5DUyAobWcpdAAMaW50Ny5DUyAobWcpdAAMaW50OC5DUyAobWcpdAAMaW50OS5DUyAobWcpdAANaW50MTAuQ1MgKG1nKXQADXRydW5rLkNTIChtZyl0AAxyb290LkNTIChtZyl0ABFpbnQxLmJpb21hc3MgKG1nKXQAEWludDIuYmlvbWFzcyAobWcpdAARaW50My5iaW9tYXNzIChtZyl0ABFpbnQ0LmJpb21hc3MgKG1nKXQAEWludDUuYmlvbWFzcyAobWcpdAARaW50Ni5iaW9tYXNzIChtZyl0ABFpbnQ3LmJpb21hc3MgKG1nKXQAEWludDguYmlvbWFzcyAobWcpdAARaW50OS5iaW9tYXNzIChtZyl0ABJpbnQxMC5iaW9tYXNzIChtZyl0ABJ0cnVuay5iaW9tYXNzIChtZyl0ABFyb290LmJpb21hc3MgKG1nKXQAD3NvdXJjZUxvYWRpbmdfYnQADlNZTlRIRVNJU19SQVRFcQB+AFV0AAhLTV9ST09UU3QACEtNX0JFUlJZdAALS01fUkVTRVJWRVN0AAxLTV9TRUNPTkRBUll0AA9IWURST0xZU0lTX1JBVEV0AAdTMTMuY3BidAAHUzE0LmNwYnQAB1MxNS5jcGJ0AAdTMTYuY3BidAAHUzEzLmNwdHQAB1MxNC5jcHR0AAdTMTUuY3B0dAAHUzE2LmNwdHQACEMxLkNmbHV4dAAWQzEuY2FyYm9uX25vblN0cnVjdHVyZXQAE0MxLmNhcmJvbl9zdHJ1Y3R1cmV0AAhDMi5DZmx1eHQAFkMyLmNhcmJvbl9ub25TdHJ1Y3R1cmV0ABNDMi5jYXJib25fc3RydWN0dXJldAAIQzMuQ2ZsdXh0ABZDNC5jYXJib25fbm9uU3RydWN0dXJldAATQzUuY2FyYm9uX3N0cnVjdHVyZXQACEM2LkNmbHV4dAAWQzcuY2FyYm9uX25vblN0cnVjdHVyZXQAE0M4LmNhcmJvbl9zdHJ1Y3R1cmV0ABJwYi5jX2NvbmNlbnRyYXRpb254cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0AB1DYXJib24gcG90ZW50aWFsIG9wdGltaXphdGlvbnA="/>
     <de.grogra.pf.registry.SharedValue name="TABLE 0" type="de.grogra.pf.data.Dataset" value="serialized:rO0ABXNyABlkZS5ncm9ncmEucGYuZGF0YS5EYXRhc2V0Pri86I/xbusCAAlaAAxzZXJpZXNJblJvd3NMAARiaW5zdAAVTGphdmEvdXRpbC9BcnJheUxpc3Q7TAANY2F0ZWdvcnlMYWJlbHQAEkxqYXZhL2xhbmcvU3RyaW5nO0wACmNvbHVtbktleXNxAH4AAUwABW9yZGVydAAcTG9yZy9qZnJlZS9kYXRhL0RvbWFpbk9yZGVyO0wAB3Jvd0tleXNxAH4AAUwABHJvd3NxAH4AAUwABXRpdGxlcQB+AAJMAAp2YWx1ZUxhYmVscQB+AAJ4cABzcgATamF2YS51dGlsLkFycmF5TGlzdHiB0h2Zx2GdAwABSQAEc2l6ZXhwAAAAAHcEAAAAAHhwc3EAfgAFAAAAfHcEAAAAfHQABHllYXJ0AAlkYXlPZlllYXJ0AAlob3VyT2ZEYXl0AAhzY2VuYXJpb3QADFN1Yi1zY2VuYXJpb3QADWFnZS1kZWdyZWVEYXl0AAhhZ2UtZGF5c3QACWNjYSAocHBtKXQACndpbmQgKG0vcyl0ABNzb2lsTkNvbnRlbnQgKGcvbTMpdAAMbGVhZkFyZWEobTIpdAAcaW5jb21pbmdSYWRpYXRpb24odW1vbC9tMi9zKXQAC1RhIChkZWdyZWUpdAACcmh0ABdzb2lsV2F0ZXJDb250ZW50KGtnL2tnKXQAE2lucHV0V2F0ZXJQb3RlbnRpYWx0AApsZWFmTnVtYmVydAAQdG90YWxGcnVpdE51bWJlcnQAHUFic29yYmVkVG90UmFkICh1bW9sL3BsYW50L3MpdAAaQWJzb3JiZWQgUEFSKHVtb2wvcGxhbnQvcyl0AApmYWJzVG90UmFkdAAHZmFic1BBUnQAB2ZQQVJMb3d0AAdmUEFSTWlkdAAGZlBBUlVwdAAWbWVhbkFuZXQodW1vbGNvMi9tMi9zKXQAIUNvMiBhc3NpbWlsYXRpb24odW1vbGNvMi9wbGFudC9zKXQAIWNhcmJvbkFzc2ltaWxhdGlvbihtZy9wbGFudC9ob3VyKXQAFXdhdGVyRmx1eChtZy9wbGFudC9zKXQADldVRShtZ0MvbWdIMm8pdAAYd2F0ZXJGbHV4UG90ZW50aWFsKG1nL3MpdAAYeHlsZW1XYXRlclBvdGVudGlhbFtNUGFddAAfcGhsb2VtQ2NvbmNlbnRyYXRpb24obWdjL21nSDJvKXQAJ3BobG9lbVN1Z2FyQ29uY2VudHJhdGlvbihtZ1N1Z2FyL21nSDJvKXQAFmZyYWN0aW9uX2xlYWZVbmxvYWRpbmd0ABdmcmFjdGlvbl9mcnVpdFVubG9hZGluZ3QAGmZyYWN0aW9uX2ZpbmVSb290VW5sb2FkaW5ndAAgZnJhY3Rpb25fc3RydWN0dXJhbFJvb3RVbmxvYWRpbmd0ABtmcmFjdGlvbl9pbnRlcm5vZGVVbmxvYWRpbmd0ABhmcmFjdGlvbl9mbG93ZXJVbmxvYWRpbmd0ABlmcmFjdGlvbl9wZXRpb2xlVW5sb2FkaW5ndAAUZnJhY3Rpb25fbGVhZkxvYWRpbmd0ABlmcmFjdGlvbl9pbnRlcm5vZGVMb2FkaW5ndAAYZnJhY3Rpb25fZmluZVJvb3RMb2FkaW5ndAAeZnJhY3Rpb25fc3RydWN0dXJhbFJvb3RMb2FkaW5ndAALbGVhZkxvYWRpbmd0AA1sZWFmVW5sb2FkaW5ndAAOZnJ1aXRVbmxvYWRpbmd0AA9maW5lUm9vdExvYWRpbmd0ABFmaW5lUm9vdFVubG9hZGluZ3QAEGludGVybm9kZUxvYWRpbmd0ABJpbnRlcm5vZGVVbmxvYWRpbmd0ABBpbnRlcm5vZGVMZWFrYWdldAAVc3RydWN0dXJhbFJvb3RMb2FkaW5ndAAXc3RydWN0dXJhbFJvb3RVbmxvYWRpbmd0AAxiaW9tYXNzUGxhbnR0AAxiaW9tYXNzRnJ1aXR0AA9iaW9tYXNzRmluZVJvb3R0AAtiaW9tYXNzTGVhZnQAEGJpb21hc3NJbnRlcm5vZGV0ABViaW9tYXNzU3RydWN0dXJhbFJvb3R0AAdsZWFmTlNDdAALZmluZVJvb3ROU0N0ABFzdHJ1Y3R1cmFsUm9vdE5TQ3QADGludGVybm9kZU5TQ3QACmdyb3d0aENvc3R0AA1tYWludGVuYW5jZURNdAApc2luZ2xlRnJ1aXRBY3RpdmVTdWNyb3NldXB0YWtlKG1nU3Vjcm9zZSl0AB5zaW5nbGVQYXNzaXZlVXB0YWtlKG1nU3Vjcm9zZSl0ABlzaW5nbGVNYXNzRmxvdyhtZ1N1Y3Jvc2UpdAAjc3VtRnJ1aXRVbmxvYWRpbmdTdWNyb3NlKG1nU3Vjcm9zZSl0AA9tYWludGVuYW5jZUxlYWZ0AA9tYWludGVuYW5jZVdvb2R0ABRtYWludGVuYW5jZUludGVybm9kZXQAD21haW50ZW5hbmNlUm9vdHQAE3N1bU1haW50ZW5hbmNlRnJ1aXR0ABJzdW1Hcm93dGhDb3N0RnJ1aXR0AA5ncm93dGhDb3N0Um9vdHQAD051cHRha2VDb3N0Um9vdHQAFnNvaWxBdmFpbGFibGVXYXRlcihrZyl0ABdzb2lsV2F0ZXJQb3RlbnRpYWxbTVBhXXQAGXJvb3RDb25kdWN0YW5jZVttZy9NUGEvc110ABlzaW5nbGVGcnVpdEZyZXNoV2VpZ2h0W2dddAAXc2luZ2xlRnJ1aXREcnlXZWlnaHRbZ110ABpzdWdhckNvbmNlbnRyYXRpb25bZy9naDIwXXQADndhdGVyVXB0YWtlW2dddAATcmVzcGlyYXRpb25XYXRlcltnXXQAFHRyYW5zcGlyYXRpb25Mb3N0W2dddAAPd2F0ZXJCYWxhbmNlW2dddAAgb3Ntb3RpY1dhdGVyUG90ZW50aWFsX2ZydWl0W01QYV10ABl0dXJnb3JQcmVzc3VyZV9mcnVpdFtNUGFddAAZd2F0ZXJQb3RlbnRpYWxfZnJ1aXRbTVBhXXQAIW9zbW90aWNXYXRlclBvdGVudGlhbF9waGxvZW1bTVBhXXQAGnR1cmdvclByZXNzdXJlX3BobG9lbVtNUGFddAAad2F0ZXJQb3RlbnRpYWxfcGhsb2VtW01QYV10ABlmcnVpdExwaGxvZW0oZy9jbTIvYmFyL2gpdAAYZnJ1aXRMeHlsZW0oZy9jbTIvYmFyL2gpdAAWcm9vdE5pdHJvZ2VuVXB0YWtlKG1nKXQAG3BsYW50Tml0cm9nZW5Db21tb25Qb29sKG1nKXQAG3BsYW50Tml0cm9nZW5Db250ZW50KG1nL21nKXQAF21lYW5MZWFmTmNvbnRlbnQobWcvbWcpdAAUbGVhZk5EZWdyYWRhdGlvbihtZyl0ABJsZWFmTlN5bnRoZXNpcyhtZyl0ABx3aG9sZVBsYW50Tml0cm9nZW5BbW91bnQobWcpdAAYbWVhblBBbmV0KHVtb2xjbzIvbTIvczEpdAAHZlBBUl9aMXQAB2ZQQVJfWjJ0AAdmUEFSX1ozdAAHZlBBUl9aNHQAA2ZzMXQAA2ZzMnQAA2ZzM3QAA2ZzNHQADWN1bUxBSV9hYm92ZTF0AA1jdW1MQUlfYWJvdmUydAANY3VtTEFJX2Fib3ZlM3QADWN1bUxBSV9hYm92ZTR0AA9tZWFuRnJ1aXRGVyhtZyl0AA5tZWFuRnJ1aXRGV19zZHQAD21lYW5GcnVpdERXKG1nKXQADm1lYW5GcnVpdERXX3NkdAAQbWVhbkZydWl0U2MoZy9nKXQADm1lYW5GcnVpdFNjX3NkdAAXbGVhZldhdGVyUG90ZW50aWFsKE1QYSl4cHNxAH4ABQAAAAB3BAAAAAB4c3EAfgAFAAAAAHcEAAAAAHh0ABJQbGFudC1sZXZlbCBvdXRwdXRw"/>
    </ref>
    <ref name="images">
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit6" objDescribes="true" systemId="pfs:images/Fruit6.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="F8T" objDescribes="true" systemId="pfs:images/F8T.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="stem.png" objDescribes="true" systemId="pfs:images/stem.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="appleLeaf.png" objDescribes="true" systemId="pfs:images/appleLeaf.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="grapevine-bark.png" objDescribes="true" systemId="pfs:images/grapevine-bark.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet1down.png" objDescribes="true" systemId="pfs:images/Pet1down.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet1top.png" objDescribes="true" systemId="pfs:images/Pet1top.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet2down.png" objDescribes="true" systemId="pfs:images/Pet2down.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet2top.png" objDescribes="true" systemId="pfs:images/Pet2top.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet3down.png" objDescribes="true" systemId="pfs:images/Pet3down.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pet3top.png" objDescribes="true" systemId="pfs:images/Pet3top.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit1.png" objDescribes="true" systemId="pfs:images/Fruit1.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit2.png" objDescribes="true" systemId="pfs:images/Fruit2.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit3.png" objDescribes="true" systemId="pfs:images/Fruit3.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit3.png 2" objDescribes="true" systemId="pfs:images/Fruit3.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit5.png" objDescribes="true" systemId="pfs:images/Fruit5.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit6.png" objDescribes="true" systemId="pfs:images/Fruit6.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit7.png" objDescribes="true" systemId="pfs:images/Fruit7.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pedoncule.png" objDescribes="true" systemId="pfs:images/Pedoncule.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Petiole.png" objDescribes="true" systemId="pfs:images/Petiole.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Rosette1d.png" objDescribes="true" systemId="pfs:images/Rosette1d.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Rosette1t.png" objDescribes="true" systemId="pfs:images/Rosette1t.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Pedoncule2.png" objDescribes="true" systemId="pfs:images/Pedoncule2.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="etamine1.png" objDescribes="true" systemId="pfs:images/etamine1.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="etamine2.png" objDescribes="true" systemId="pfs:images/etamine2.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Sepale.png" objDescribes="true" systemId="pfs:images/Sepale.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="petiole1.png" objDescribes="true" systemId="pfs:images/petiole1.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="petiole2.png" objDescribes="true" systemId="pfs:images/petiole2.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="bourse.png" objDescribes="true" systemId="pfs:images/bourse.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="F6D.png" objDescribes="true" systemId="pfs:images/F6D.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="F6T.png" objDescribes="true" systemId="pfs:images/F6T.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
     <de.grogra.pf.ui.registry.FileObjectItem mimeType="image/png" name="Fruit4.png" objDescribes="true" systemId="pfs:images/Fruit4.png" type="de.grogra.imp.objects.FixedImageAdapter"/>
    </ref>
    <ref name="meta">
     <de.grogra.pf.registry.NodeReference name="updatesBase" ref="26023590"/>
     <de.grogra.pf.registry.NodeReference name="developBase" ref="26023591"/>
     <de.grogra.pf.registry.NodeReference name="main" ref="30631619"/>
     <de.grogra.pf.registry.NodeReference name="charts" ref="30631621"/>
     <de.grogra.pf.registry.NodeReference name="outputTables" ref="30631622"/>
     <de.grogra.pf.registry.NodeReference name="diagnosticTables" ref="30631623"/>
     <de.grogra.pf.registry.NodeReference name="updatesBase 2" ref="30631624"/>
     <de.grogra.pf.registry.NodeReference name="developBase 2" ref="30631625"/>
     <de.grogra.pf.registry.NodeReference name="globalParameters" ref="30631626"/>
     <de.grogra.pf.registry.NodeReference name="plantParameters" ref="30631628"/>
     <de.grogra.pf.registry.NodeReference name="simRunBase" ref="30631629"/>
     <de.grogra.pf.registry.NodeReference name="initiationBase" ref="30631630"/>
     <de.grogra.pf.registry.NodeReference name="initialConditions" ref="30631631"/>
     <de.grogra.pf.registry.NodeReference name="modelOptions" ref="30631632"/>
     <de.grogra.pf.registry.NodeReference name="plantBase" ref="30631633"/>
     <de.grogra.pf.registry.NodeReference name="shootBase" ref="30631634"/>
     <de.grogra.pf.registry.NodeReference name="fieldBase" ref="30631635"/>
     <de.grogra.pf.registry.NodeReference name="interfaces" ref="30631636"/>
     <de.grogra.pf.registry.NodeReference name="budBase" ref="30631637"/>
     <de.grogra.pf.registry.NodeReference name="flowerBase" ref="30631638"/>
     <de.grogra.pf.registry.NodeReference name="fruitBase" ref="30631639"/>
     <de.grogra.pf.registry.NodeReference name="absOrgan" ref="30631640"/>
     <de.grogra.pf.registry.NodeReference name="rootSystem" ref="30631641"/>
     <de.grogra.pf.registry.NodeReference name="fineRoot" ref="30631642"/>
     <de.grogra.pf.registry.NodeReference name="structuralRoot" ref="30631643"/>
     <de.grogra.pf.registry.NodeReference name="leaf" ref="30631644"/>
     <de.grogra.pf.registry.NodeReference name="shoot" ref="30631645"/>
     <de.grogra.pf.registry.NodeReference name="canopy" ref="30631646"/>
     <de.grogra.pf.registry.NodeReference name="soil" ref="30631647"/>
     <de.grogra.pf.registry.NodeReference name="environment" ref="30631648"/>
     <de.grogra.pf.registry.NodeReference name="lightInterception" ref="30631649"/>
     <de.grogra.pf.registry.NodeReference name="photosynthesisAndTranspiration" ref="30631650"/>
     <de.grogra.pf.registry.NodeReference name="plantHydraulics" ref="30631651"/>
     <de.grogra.pf.registry.NodeReference name="carbonAllocation" ref="30631652"/>
     <de.grogra.pf.registry.NodeReference name="carbonTransport" ref="30631653"/>
     <de.grogra.pf.registry.NodeReference name="phenology" ref="30631654"/>
     <de.grogra.pf.registry.NodeReference name="leafAngleOptimization" ref="30631655"/>
     <de.grogra.pf.registry.NodeReference name="structuralVariation" ref="30631656"/>
     <de.grogra.pf.registry.NodeReference name="pruning" ref="30631657"/>
     <de.grogra.pf.registry.NodeReference name="shootPositioning" ref="30631658"/>
     <de.grogra.pf.registry.NodeReference name="twinningPlanner" ref="30631659"/>
     <de.grogra.pf.registry.NodeReference name="budPlanner" ref="30631660"/>
     <de.grogra.pf.registry.NodeReference name="budPlannerConfig" ref="30631661"/>
     <de.grogra.pf.registry.NodeReference name="budPlannerT0" ref="30631662"/>
     <de.grogra.pf.registry.NodeReference name="budPlannerT1" ref="30631663"/>
     <de.grogra.pf.registry.NodeReference name="budReflectionUtils" ref="30631664"/>
     <de.grogra.pf.registry.NodeReference name="leafPlanner" ref="30631665"/>
     <de.grogra.pf.registry.NodeReference name="fruitPlanner" ref="30631666"/>
     <de.grogra.pf.registry.NodeReference name="updatesApple" ref="30631667"/>
     <de.grogra.pf.registry.NodeReference name="updatesSingleRoot" ref="30631668"/>
     <de.grogra.pf.registry.NodeReference name="updatesGrapevine" ref="30631669"/>
     <de.grogra.pf.registry.NodeReference name="updatesBerryPopulation" ref="30631670"/>
     <de.grogra.pf.registry.NodeReference name="updatesVirtualFruit" ref="30631671"/>
     <de.grogra.pf.registry.NodeReference name="simRunStandard" ref="30631672"/>
     <de.grogra.pf.registry.NodeReference name="simRunBerryPopulation" ref="30631673"/>
     <de.grogra.pf.registry.NodeReference name="simRunOptimalCanopyArchitecture" ref="30631674"/>
     <de.grogra.pf.registry.NodeReference name="simRunIdealVine" ref="30631675"/>
     <de.grogra.pf.registry.NodeReference name="initiationVirtualFruit" ref="30631676"/>
     <de.grogra.pf.registry.NodeReference name="initiationSingleRoot" ref="30631677"/>
     <de.grogra.pf.registry.NodeReference name="initiationSingleLeaf" ref="30631678"/>
     <de.grogra.pf.registry.NodeReference name="initiationBerryPopulation" ref="30631679"/>
     <de.grogra.pf.registry.NodeReference name="initiationStructuralVariation" ref="30631680"/>
     <de.grogra.pf.registry.NodeReference name="initiationOptimalCanopyArchitecture" ref="30631681"/>
     <de.grogra.pf.registry.NodeReference name="initiationStandard" ref="30631682"/>
     <de.grogra.pf.registry.NodeReference name="initiationArchReader" ref="30631683"/>
     <de.grogra.pf.registry.NodeReference name="initiationArchReaderGPU" ref="30631684"/>
     <de.grogra.pf.registry.NodeReference name="initiationStandardGridClone" ref="30631685"/>
     <de.grogra.pf.registry.NodeReference name="initiationFieldRandomCanopy" ref="30631686"/>
     <de.grogra.pf.registry.NodeReference name="developApple" ref="30631687"/>
     <de.grogra.pf.registry.NodeReference name="developGrapevine" ref="30631688"/>
     <de.grogra.pf.registry.NodeReference name="developGrapevineStructuralVariation" ref="30631689"/>
     <de.grogra.pf.registry.NodeReference name="flowerApple" ref="30631690"/>
     <de.grogra.pf.registry.NodeReference name="budApple" ref="30631691"/>
     <de.grogra.pf.registry.NodeReference name="budGrapevine" ref="30631692"/>
     <de.grogra.pf.registry.NodeReference name="virtualFruit" ref="30631693"/>
     <de.grogra.pf.registry.NodeReference name="berryComplex" ref="30631694"/>
     <de.grogra.pf.registry.NodeReference name="berrySimple" ref="30631695"/>
     <de.grogra.pf.registry.NodeReference name="berryYield" ref="30631696"/>
     <de.grogra.pf.registry.NodeReference name="extraTools" ref="30631697"/>
     <de.grogra.pf.registry.NodeReference name="dataset" ref="30631698"/>
     <de.grogra.pf.registry.NodeReference name="leafShape" ref="30631699"/>
     <de.grogra.pf.registry.NodeReference name="server" ref="30631700"/>
     <de.grogra.pf.registry.NodeReference name="socketRun" ref="30631701"/>
     <de.grogra.pf.registry.NodeReference name="tests" ref="30631702"/>
     <de.grogra.pf.registry.NodeReference name="tasks" ref="30631703"/>
     <de.grogra.pf.registry.NodeReference name="validation" ref="30631704"/>
     <de.grogra.pf.registry.NodeReference name="validationTests" ref="30631705"/>
     <de.grogra.pf.registry.NodeReference name="archReader" ref="30631706"/>
     <de.grogra.pf.registry.NodeReference name="aggregatedRoot" ref="30631707"/>
     <de.grogra.pf.registry.NodeReference name="fieldCanopyReader" ref="30631708"/>
    </ref>
    <ref name="3d">
     <ref name="shaders">
      <de.grogra.pf.registry.SONodeReference name="appleLeaf" objDescribes="true" ref="1632863"/>
      <de.grogra.pf.registry.SONodeReference name="woodStem" objDescribes="true" ref="1632865"/>
      <de.grogra.pf.registry.SONodeReference name="cordonStem" objDescribes="true" ref="1632867"/>
      <de.grogra.pf.registry.SONodeReference name="appleSkin" objDescribes="true" ref="1632869"/>
      <de.grogra.pf.registry.SONodeReference name="etamine1" objDescribes="true" ref="1633289"/>
      <de.grogra.pf.registry.SONodeReference name="etamine2" objDescribes="true" ref="1633423"/>
      <de.grogra.pf.registry.SONodeReference name="pet1D" objDescribes="true" ref="1633425"/>
      <de.grogra.pf.registry.SONodeReference name="pet1T" objDescribes="true" ref="1633427"/>
      <de.grogra.pf.registry.SONodeReference name="pet2D" objDescribes="true" ref="1633429"/>
      <de.grogra.pf.registry.SONodeReference name="pet2T" objDescribes="true" ref="1633431"/>
      <de.grogra.pf.registry.SONodeReference name="pet3D" objDescribes="true" ref="1633433"/>
      <de.grogra.pf.registry.SONodeReference name="pet3T" objDescribes="true" ref="1633435"/>
      <de.grogra.pf.registry.SONodeReference name="sepal" objDescribes="true" ref="1633437"/>
      <de.grogra.pf.registry.SONodeReference name="peto1" objDescribes="true" ref="1633439"/>
      <de.grogra.pf.registry.SONodeReference name="peto2" objDescribes="true" ref="1633441"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme1" objDescribes="true" ref="1633443"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme2" objDescribes="true" ref="1633445"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme3" objDescribes="true" ref="1633447"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme4" objDescribes="true" ref="1633449"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme5" objDescribes="true" ref="1633451"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme6" objDescribes="true" ref="1633453"/>
      <de.grogra.pf.registry.SONodeReference name="Pomme7" objDescribes="true" ref="1633455"/>
      <de.grogra.pf.registry.SONodeReference name="pedoncule" objDescribes="true" ref="1633457"/>
      <de.grogra.pf.registry.SONodeReference name="petiole" objDescribes="true" ref="1633459"/>
      <de.grogra.pf.registry.SONodeReference name="R1D" objDescribes="true" ref="1633461"/>
      <de.grogra.pf.registry.SONodeReference name="R1T" objDescribes="true" ref="1633463"/>
      <de.grogra.pf.registry.SONodeReference name="pedoncule2" objDescribes="true" ref="1633587"/>
     </ref>
    </ref>
   </ref>
   <ref name="layouts">
    <de.grogra.pf.ui.registry.Layout name="Layout">
     <de.grogra.pf.ui.registry.MainWindow name="_">
      <de.grogra.pf.ui.registry.Split location="0.50994766" name="_">
       <de.grogra.pf.ui.registry.Split location="0.70223576" name="_" orientation="0">
        <de.grogra.pf.ui.registry.Split name="_" orientation="0">
         <de.grogra.pf.registry.Link name="_" source="/ui/panels/rgg/toolbar"/>
         <de.grogra.pf.ui.registry.PanelFactory name="_0" source="/ui/panels/3d/defaultview">
          <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/3d/defaultview"/>
          <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="View"/>
          <de.grogra.pf.registry.Option name="view" type="de.grogra.imp3d.View3D" value="graphDescriptor=[de.grogra.imp.ProjectGraphDescriptor]visibleScales={false false false false false}visibleLayers={true true true true true true false true true true true false false false false false}epsilon=1.0E-6 visualEpsilon=0.01 magnitude=1.0 camera=(minZ=0.1 maxZ=2000.0 projection=[de.grogra.imp3d.PerspectiveProjection aspect=1.0 fieldOfView=1.0471976]transformation=(-0.15672910422181796 -0.9876416292814014 0.0 -0.5455141998901283 0.08737434696869044 -0.013865457597535678 0.996079049361375 -0.8437670864712244 -0.9837691352043686 0.15611457714050467 0.08846766314647878 -3.578090531687317 0.0 0.0 0.0 1.0))eventFactory=null"/>
         </de.grogra.pf.ui.registry.PanelFactory>
        </de.grogra.pf.ui.registry.Split>
        <de.grogra.pf.ui.registry.Split name="_0" orientation="0">
         <de.grogra.pf.ui.registry.Tab name="_" selectedIndex="1">
          <de.grogra.pf.registry.Link name="_" source="/ui/panels/fileexplorer"/>
          <de.grogra.pf.registry.Link name="_0" source="/ui/panels/objects/meta"/>
         </de.grogra.pf.ui.registry.Tab>
         <de.grogra.pf.registry.Link name="_0" source="/ui/panels/statusbar"/>
        </de.grogra.pf.ui.registry.Split>
       </de.grogra.pf.ui.registry.Split>
       <de.grogra.pf.ui.registry.Split location="0.46646342" name="_0" orientation="0">
        <de.grogra.pf.registry.Link name="_" source="/ui/panels/attributeeditor"/>
        <de.grogra.pf.ui.registry.Tab name="_0" selectedIndex="0">
         <de.grogra.pf.registry.Link name="_" source="/ui/panels/log"/>
         <de.grogra.pf.registry.Link name="_0" source="/ui/panels/rgg/console"/>
        </de.grogra.pf.ui.registry.Tab>
       </de.grogra.pf.ui.registry.Split>
      </de.grogra.pf.ui.registry.Split>
     </de.grogra.pf.ui.registry.MainWindow>
     <de.grogra.pf.ui.registry.FloatingWindow height="1056" name="_0" width="1936">
      <de.grogra.pf.ui.registry.PanelFactory name="_" source="/ui/panels/texteditor">
       <de.grogra.pf.registry.Option name="documents" type="java.lang.String" value="&quot;\&quot;C:\\\\Users\\\\hrmexj\\\\Untitled-1\&quot;&quot;"/>
       <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/texteditor"/>
       <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="jEdit - Untitled-1"/>
       <de.grogra.pf.registry.Option name="selected" type="java.lang.String" value="C:\Users\hrmexj\Untitled-1"/>
      </de.grogra.pf.ui.registry.PanelFactory>
     </de.grogra.pf.ui.registry.FloatingWindow>
    </de.grogra.pf.ui.registry.Layout>
   </ref>
  </ref>
  <ref name="workbench">
   <ref name="state">
    <de.grogra.pf.ui.registry.Layout name="layout">
     <de.grogra.pf.ui.registry.MainWindow>
      <de.grogra.pf.ui.registry.Split location="0.81474876">
       <de.grogra.pf.ui.registry.Split location="0.4893773">
        <de.grogra.pf.ui.registry.Split orientation="0">
         <de.grogra.pf.registry.Link source="/ui/panels/rgg/toolbar"/>
         <de.grogra.pf.ui.registry.Split location="0.54524887">
          <de.grogra.pf.ui.registry.Split orientation="0">
           <de.grogra.pf.registry.Link source="/ui/panels/coolbar"/>
           <de.grogra.pf.ui.registry.Split location="0.5180624" orientation="0">
            <de.grogra.pf.ui.registry.PanelFactory source="/ui/panels/3d/defaultview">
             <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/3d/defaultview"/>
             <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="View"/>
             <de.grogra.pf.registry.Option name="view" type="de.grogra.imp3d.View3D" value="graphDescriptor=[de.grogra.imp.ProjectGraphDescriptor]visibleScales={true true true true true true true true true true true true true true true}visibleLayers={true true true true true true true false true true true true true true true true}epsilon=1.0E-6 visualEpsilon=0.01 magnitude=1.0 camera=(minZ=0.1 maxZ=2000.0 projection=[de.grogra.imp3d.PerspectiveProjection aspect=1.0 fieldOfView=1.0471976]transformation=(-0.04056315575620492 0.9991769765137201 0.0 -3.9674992222338945 -0.31900251125795953 -0.012950407039928141 0.9476653864991693 -4.700445647165177 0.9468854356289477 0.03844029867732919 0.31926527407687827 -13.800924338400364 0.0 0.0 0.0 1.0))eventFactory=[de.grogra.imp3d.DefaultView3DEventFactory]"/>
            </de.grogra.pf.ui.registry.PanelFactory>
            <de.grogra.pf.registry.Link source="/ui/panels/objects/3d/shaders"/>
           </de.grogra.pf.ui.registry.Split>
          </de.grogra.pf.ui.registry.Split>
          <de.grogra.pf.ui.registry.Tab selectedIndex="0">
           <de.grogra.pf.registry.Link source="/ui/panels/fileexplorer"/>
           <de.grogra.pf.registry.Link source="/ui/panels/attributeeditor"/>
          </de.grogra.pf.ui.registry.Tab>
         </de.grogra.pf.ui.registry.Split>
        </de.grogra.pf.ui.registry.Split>
        <de.grogra.pf.ui.registry.PanelFactory source="/ui/panels/texteditor">
         <de.grogra.pf.registry.Option name="documents" type="java.lang.String" value="&quot;\&quot;pfs:organs/absOrgans/absOrgan.rgg\&quot;,\&quot;pfs:utils/archReader.rgg\&quot;,\&quot;pfs:organs/rootSystem/fineRoot.rgg\&quot;,\&quot;pfs:config/globalParameters.rgg\&quot;,\&quot;pfs:main/main.rgg\&quot;,\&quot;pfs:organs/rootSystem/rootSystem.rgg\&quot;,\&quot;pfs:organs/shoot.rgg\&quot;,\&quot;pfs:environment/soil.rgg\&quot;&quot;"/>
         <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/texteditor"/>
         <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="jEdit - globalParameters.rgg"/>
         <de.grogra.pf.registry.Option name="selected" type="java.lang.String" value="pfs:config/globalParameters.rgg"/>
        </de.grogra.pf.ui.registry.PanelFactory>
       </de.grogra.pf.ui.registry.Split>
       <de.grogra.pf.ui.registry.Tab selectedIndex="0">
        <de.grogra.pf.registry.Link source="/ui/panels/rgg/console"/>
        <de.grogra.pf.registry.Link source="/ui/panels/log"/>
       </de.grogra.pf.ui.registry.Tab>
      </de.grogra.pf.ui.registry.Split>
     </de.grogra.pf.ui.registry.MainWindow>
    </de.grogra.pf.ui.registry.Layout>
   </ref>
  </ref>
 </registry>
</project>
