import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("carbon-transport-mass-balance-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CarbonTransportMassBalanceDiagnosticOutputData implements Serializable {
	private static final long serialVersionUID = 1L;

	@JsonProperty(value = "timestamp", index = 0)
	@JsonPropertyDescription("Simulation time stamp in ISO 8601 format.")
	@Tags("Timing")
	public String timestamp;

	@JsonProperty(value = "step", index = 1)
	@JsonPropertyDescription("Simulation step represented by the diagnostic row.")
	@Tags("Timing")
	public int step;

	@JsonProperty(value = "year", index = 2)
	@JsonPropertyDescription("Simulation year.")
	@Tags("Timing")
	public int year;

	@JsonProperty(value = "dayOfYear", index = 3)
	@JsonPropertyDescription("Simulation day of year.")
	@Tags("Timing")
	public int dayOfYear;

	@JsonProperty(value = "hourOfDay", index = 4)
	@JsonPropertyDescription("Simulation hour of day.")
	@Tags("Timing")
	public int hourOfDay;

	@JsonProperty(value = "scenario", index = 5)
	@JsonPropertyDescription("Internal scenario number for the simulation.")
	@Tags("Identifiers")
	public int scenario;

	@JsonProperty(value = "simuuid", index = 6)
	@JsonPropertyDescription("Unique simulation UUID assigned to the run.")
	@Tags("Identifiers")
	public String simuuid;

	@JsonProperty(value = "plantNumber", index = 7)
	@JsonPropertyDescription("Plant identifier associated with the diagnostic row.")
	@Tags("Identifiers")
	public int plantNumber;

	@JsonProperty(value = "fieldInstanceId", index = 8)
	@JsonPropertyDescription("Field-instance identifier associated with the diagnostic row.")
	@Tags("Identifiers")
	public int fieldInstanceId;

	@JsonProperty(value = "day", index = 9)
	@JsonPropertyDescription("Legacy simulation day value retained from the carbon-transport diagnostic.")
	@Tags("Timing")
	public int day;

	@JsonProperty(value = "hour", index = 10)
	@JsonPropertyDescription("Legacy simulation hour value retained from the carbon-transport diagnostic.")
	@Tags("Timing")
	public int hour;

	@JsonProperty(value = "useCPStyleCTResponse", index = 11)
	@JsonPropertyDescription("Whether the carbon-potential response formulation was used.")
	@Tags("Solver diagnostics")
	public boolean useCPStyleCTResponse;

	@JsonProperty(value = "iterationCount", index = 12)
	@JsonPropertyDescription("Number of iterations completed by the carbon-transport solve.")
	@Tags("Solver diagnostics")
	public int iterationCount;

	@JsonProperty(value = "convergenceError", index = 13)
	@JsonPropertyDescription("Final summed absolute carbon-flux convergence error.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double convergenceError;

	@JsonProperty(value = "totalLoading", index = 14)
	@JsonPropertyDescription("Absolute sum of solved source-loading fluxes for the plant.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double totalLoading;

	@JsonProperty(value = "totalUnloading", index = 15)
	@JsonPropertyDescription("Sum of solved sink-unloading fluxes for the plant.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double totalUnloading;

	@JsonProperty(value = "netFluxResidual", index = 16)
	@JsonPropertyDescription("Total loading minus total unloading for the solved plant.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double netFluxResidual;

	@JsonProperty(value = "relativeFluxResidual", index = 17)
	@JsonPropertyDescription("Absolute net-flux residual relative to the larger loading or unloading magnitude.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double relativeFluxResidual;

	@JsonProperty(value = "minCp", index = 18)
	@JsonPropertyDescription("Minimum organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double minCp;

	@JsonProperty(value = "maxCp", index = 19)
	@JsonPropertyDescription("Maximum organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double maxCp;

	@JsonProperty(value = "meanCp", index = 20)
	@JsonPropertyDescription("Mean organ carbon potential in the solved plant.")
	@Unit("(g C/cm3)^2")
	@Tags("Carbon")
	public double meanCp;

	@JsonProperty(value = "minSugar", index = 21)
	@JsonPropertyDescription("Sugar concentration transformed from the minimum organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double minSugar;

	@JsonProperty(value = "maxSugar", index = 22)
	@JsonPropertyDescription("Sugar concentration transformed from the maximum organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double maxSugar;

	@JsonProperty(value = "meanSugar", index = 23)
	@JsonPropertyDescription("Sugar concentration transformed from the mean organ carbon potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double meanSugar;

	@JsonProperty(value = "ctPlantBaseFallbackUsed", index = 24)
	@JsonPropertyDescription("Whether the current PlantBase boundary retained a previous potential or used the numerical floor.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackUsed;

	@JsonProperty(value = "ctPlantBaseFallbackReason", index = 25)
	@JsonPropertyDescription("PlantBase boundary outcome code: 0 accepted root; 1 non-finite coefficient; 2 zero or near-zero denominator; 3 invalid candidate; 4 invalid transformed sugar.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackReason;

	@JsonProperty(value = "ctPlantBaseFallbackCount", index = 26)
	@JsonPropertyDescription("Cumulative number of guarded PlantBase boundary fallbacks for the plant.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public int ctPlantBaseFallbackCount;

	@JsonProperty(value = "ctPlantBaseResidual", index = 27)
	@JsonPropertyDescription("Folded boundary residual A + B Phi at the accepted or retained PlantBase potential.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double ctPlantBaseResidual;

	@JsonProperty(value = "ctPlantBaseDenominator", index = 28)
	@JsonPropertyDescription("Folded PlantBase B coefficient used to assess and solve the zero-net-flow boundary.")
	@Unit("g C/h/((g C/cm3)^2)")
	@Tags("Solver diagnostics")
	public double ctPlantBaseDenominator;

	@JsonProperty(value = "absoluteFluxError", index = 29)
	@JsonPropertyDescription("Final sum of absolute organ-flux changes used by the mixed convergence test.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double absoluteFluxError;

	@JsonProperty(value = "relativeFluxConvergenceError", index = 30)
	@JsonPropertyDescription("Absolute flux-change error divided by the larger old or new total absolute flux.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double relativeFluxConvergenceError;

	@JsonProperty(value = "ctPlantBaseAbsoluteResidual", index = 31)
	@JsonPropertyDescription("Absolute folded PlantBase boundary residual after under-relaxation.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double ctPlantBaseAbsoluteResidual;

	@JsonProperty(value = "ctPlantBaseRelativeResidual", index = 32)
	@JsonPropertyDescription("Absolute PlantBase residual relative to the local folded-boundary flux scale.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double ctPlantBaseRelativeResidual;

	@JsonProperty(value = "ctDampingFactor", index = 33)
	@JsonPropertyDescription("Under-relaxation factor used for the final accepted PlantBase potential.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double ctDampingFactor;

	@JsonProperty(value = "ctRawPlantBasePhi", index = 34)
	@JsonPropertyDescription("Guarded raw PlantBase potential candidate before under-relaxation.")
	@Unit("(g C/cm3)^2")
	@Tags("Solver diagnostics")
	public double ctRawPlantBasePhi;

	@JsonProperty(value = "ctAcceptedPlantBasePhi", index = 35)
	@JsonPropertyDescription("PlantBase potential installed after under-relaxation.")
	@Unit("(g C/cm3)^2")
	@Tags("Solver diagnostics")
	public double ctAcceptedPlantBasePhi;

	@JsonProperty(value = "ctConverged", index = 36)
	@JsonPropertyDescription("Whether the existing mixed flux-change and PlantBase boundary criteria passed without invalid simple-root topology or traversal.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctConverged;

	@JsonProperty(value = "ctMaxIterationReached", index = 37)
	@JsonPropertyDescription("Whether the solve stopped at the configured iteration limit without convergence.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctMaxIterationReached;

	@JsonProperty(value = "ctNonlinearMerit", index = 38)
	@JsonPropertyDescription("Maximum normalized mixed-tolerance error across flux change and the PlantBase boundary.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double ctNonlinearMerit;

	@JsonProperty(value = "ctRetryUsed", index = 39)
	@JsonPropertyDescription("Whether the normal 30-iteration solve failed and the single retry was used.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctRetryUsed;

	@JsonProperty(value = "ctRetryConverged", index = 40)
	@JsonPropertyDescription("Whether the single retry converged and its state was accepted.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctRetryConverged;

	@JsonProperty(value = "ctSolverFallbackUsed", index = 41)
	@JsonPropertyDescription("Whether both attempts failed and the accepted pre-hour transport state was restored.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctSolverFallbackUsed;

	@JsonProperty(value = "ctInvalidUnfoldTrialCount", index = 42)
	@JsonPropertyDescription("Total invalid raw or accepted organ Phi trials across the normal solve and retry.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public int ctInvalidUnfoldTrialCount;

	@JsonProperty(value = "ctFinalIterationLimit", index = 43)
	@JsonPropertyDescription("Iteration limit of the final solver attempt (30 normal or 60 retry).")
	@Unit("iterations")
	@Tags("Solver diagnostics")
	public int ctFinalIterationLimit;

	@JsonProperty(value = "ctBootstrapFallbackUsed", index = 44)
	@JsonPropertyDescription("Whether initialization was restored provisionally because no converged hourly CT state existed.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctBootstrapFallbackUsed;

	@JsonProperty(value = "ctHasAcceptedHourlyState", index = 45)
	@JsonPropertyDescription("Whether at least one genuinely converged hourly CT solution has been committed.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean ctHasAcceptedHourlyState;

	@JsonProperty(value = "ctStoredPlantBaseSugar", index = 46)
	@JsonPropertyDescription("PlantBase phloem sugar stored after convergence or rollback.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double ctStoredPlantBaseSugar;

	@JsonProperty(value = "ctPlantBaseSugarFromPhi", index = 47)
	@JsonPropertyDescription("PlantBase phloem sugar transformed directly from the post-solve or restored cpt potential.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double ctPlantBaseSugarFromPhi;

	@JsonProperty(value = "ctAcceptedHourlyPlantBaseSugar", index = 48)
	@JsonPropertyDescription("PlantBase sugar of the committed/restored converged hourly state; zero when no such state exists.")
	@Unit("g sugar/cm3")
	@Tags("Carbon")
	public double ctAcceptedHourlyPlantBaseSugar;

	@JsonProperty(value = "ctFailedTrialPlantBasePhi", index = 49)
	@JsonPropertyDescription("PlantBase potential of the final complete finite nonlinear trial before rollback.")
	@Unit("(g C/cm3)^2")
	@Tags("Solver diagnostics")
	public double ctFailedTrialPlantBasePhi;

	@JsonProperty(value = "ctFailedTrialPlantBaseSugar", index = 50)
	@JsonPropertyDescription("PlantBase sugar transformed from the final complete finite nonlinear trial before rollback.")
	@Unit("g sugar/cm3")
	@Tags("Solver diagnostics")
	public double ctFailedTrialPlantBaseSugar;

	@JsonProperty(value = "ctFailedTrialMinSugar", index = 51)
	@JsonPropertyDescription("Minimum organ sugar in the final complete finite nonlinear trial before rollback.")
	@Unit("g sugar/cm3")
	@Tags("Solver diagnostics")
	public double ctFailedTrialMinSugar;

	@JsonProperty(value = "ctFailedTrialMaxSugar", index = 52)
	@JsonPropertyDescription("Maximum organ sugar in the final complete finite nonlinear trial before rollback.")
	@Unit("g sugar/cm3")
	@Tags("Solver diagnostics")
	public double ctFailedTrialMaxSugar;

	@JsonProperty(value = "ctFailedTrialMeanSugar", index = 53)
	@JsonPropertyDescription("Mean organ sugar in the final complete finite nonlinear trial before rollback.")
	@Unit("g sugar/cm3")
	@Tags("Solver diagnostics")
	public double ctFailedTrialMeanSugar;

	@JsonProperty(value = "ctFailedTrialMerit", index = 54)
	@JsonPropertyDescription("Mixed nonlinear merit of the final complete finite nonlinear trial before rollback.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double ctFailedTrialMerit;

	@JsonProperty(value = "sumLocalJ", index = 55)
	@JsonPropertyDescription("Signed sum of all solved local GrowingOrgan carbon currents.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double sumLocalJ;

	@JsonProperty(value = "pbFoldedJ", index = 56)
	@JsonPropertyDescription("Folded PlantBase current A plus B Phi for the final nonlinear pass.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double pbFoldedJ;

	@JsonProperty(value = "closureResidual", index = 57)
	@JsonPropertyDescription("Signed graph-closure residual sumLocalJ minus pbFoldedJ.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double closureResidual;

	@JsonProperty(value = "closureScale", index = 58)
	@JsonPropertyDescription("Graph-closure scale: maximum of total absolute local current, absolute PlantBase current, and numerical epsilon.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double closureScale;

	@JsonProperty(value = "relativeClosureResidual", index = 59)
	@JsonPropertyDescription("Absolute graph-closure residual divided by closureScale.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double relativeClosureResidual;

	@JsonProperty(value = "closureNormalizedError", index = 60)
	@JsonPropertyDescription("Graph-closure error normalized by the active mixed CT tolerances.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double closureNormalizedError;

	@JsonProperty(value = "netFluxIdentityResidual", index = 61)
	@JsonPropertyDescription("Numerical check netFluxResidual plus sumLocalJ; zero confirms loading/unloading sign categorization.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double netFluxIdentityResidual;

	@JsonProperty(value = "totalGrowingOrganCount", index = 62)
	@JsonPropertyDescription("Number of transport-participating GrowingOrgan objects in the plant scope.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long totalGrowingOrganCount;

	@JsonProperty(value = "foldedGrowingOrganCount", index = 63)
	@JsonPropertyDescription("Number of GrowingOrgan objects contributing to exactly one fold owner in the final pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long foldedGrowingOrganCount;

	@JsonProperty(value = "unfoldedGrowingOrganCount", index = 64)
	@JsonPropertyDescription("Number of GrowingOrgan objects receiving Phi from exactly one unfold owner in the final pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long unfoldedGrowingOrganCount;

	@JsonProperty(value = "foldCoverageComplete", index = 65)
	@JsonPropertyDescription("Whether every scoped GrowingOrgan contributed through exactly one fold owner.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean foldCoverageComplete;

	@JsonProperty(value = "unfoldCoverageComplete", index = 66)
	@JsonPropertyDescription("Whether every scoped GrowingOrgan received Phi from exactly one unfold owner.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean unfoldCoverageComplete;

	@JsonProperty(value = "sumLeafJ", index = 67)
	@JsonPropertyDescription("Signed sum of stored final Leaf currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumLeafJ;

	@JsonProperty(value = "sumLeafTaylorJ", index = 68)
	@JsonPropertyDescription("Signed sum of Leaf local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumLeafTaylorJ;

	@JsonProperty(value = "sumPetioleJ", index = 69)
	@JsonPropertyDescription("Signed sum of stored final Petiole currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumPetioleJ;

	@JsonProperty(value = "sumPetioleTaylorJ", index = 70)
	@JsonPropertyDescription("Signed sum of Petiole local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumPetioleTaylorJ;

	@JsonProperty(value = "sumShootJ", index = 71)
	@JsonPropertyDescription("Signed sum of stored final Internode, Cordon, and Trunk currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumShootJ;

	@JsonProperty(value = "sumShootTaylorJ", index = 72)
	@JsonPropertyDescription("Signed sum of shoot-axis local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumShootTaylorJ;

	@JsonProperty(value = "sumFruitJ", index = 73)
	@JsonPropertyDescription("Signed sum of stored final FruitService currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFruitJ;

	@JsonProperty(value = "sumFruitTaylorJ", index = 74)
	@JsonPropertyDescription("Signed sum of fruit local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFruitTaylorJ;

	@JsonProperty(value = "sumFlowerJ", index = 75)
	@JsonPropertyDescription("Signed sum of stored final Flower currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFlowerJ;

	@JsonProperty(value = "sumFlowerTaylorJ", index = 76)
	@JsonPropertyDescription("Signed sum of Flower local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFlowerTaylorJ;

	@JsonProperty(value = "sumFineRootJ", index = 77)
	@JsonPropertyDescription("Signed sum of stored final FineRoot currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFineRootJ;

	@JsonProperty(value = "sumFineRootTaylorJ", index = 78)
	@JsonPropertyDescription("Signed sum of FineRoot local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumFineRootTaylorJ;

	@JsonProperty(value = "sumStructuralRootJ", index = 79)
	@JsonPropertyDescription("Signed sum of stored final StructuralRoot currents.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumStructuralRootJ;

	@JsonProperty(value = "sumStructuralRootTaylorJ", index = 80)
	@JsonPropertyDescription("Signed sum of StructuralRoot local Taylor values A plus B Phi.")
	@Unit("g C/h")
	@Tags("Carbon")
	public double sumStructuralRootTaylorJ;

	@JsonProperty(value = "sumFruitExactUnloading", index = 81)
	@JsonPropertyDescription("Signed sum of non-mutating exact fruit active unloading plus direct mass flow at final local Phi.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double sumFruitExactUnloading;

	@JsonProperty(value = "sumFruitExactActive", index = 82)
	@JsonPropertyDescription("Signed sum of non-mutating exact active fruit unloading at final local Phi.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double sumFruitExactActive;

	@JsonProperty(value = "sumFruitExactMassFlow", index = 83)
	@JsonPropertyDescription("Signed sum of non-mutating exact direct fruit mass flow at final local Phi.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double sumFruitExactMassFlow;

	@JsonProperty(value = "sumFruitStoredUnloading", index = 84)
	@JsonPropertyDescription("Signed sum of fruit unloading bookkeeping values observed in the final nonlinear pass before accepted carbon-status commit.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double sumFruitStoredUnloading;

	@JsonProperty(value = "fruitLinearizationResidual", index = 85)
	@JsonPropertyDescription("Signed residual sumFruitJ minus sumFruitExactUnloading.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double fruitLinearizationResidual;

	@JsonProperty(value = "fruitLinearizationRelativeResidual", index = 86)
	@JsonPropertyDescription("Absolute aggregate fruit linearization residual relative to solved or exact fruit import magnitude.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double fruitLinearizationRelativeResidual;

	@JsonProperty(value = "maxFruitLinearizationResidual", index = 87)
	@JsonPropertyDescription("Largest absolute per-fruit solved-current versus exact-unloading residual.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double maxFruitLinearizationResidual;

	@JsonProperty(value = "maxFruitLinearizationRelativeResidual", index = 88)
	@JsonPropertyDescription("Largest relative per-fruit solved-current versus exact-unloading residual.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double maxFruitLinearizationRelativeResidual;

	@JsonProperty(value = "maxFruitResidualOrganID", index = 89)
	@JsonPropertyDescription("Graph node identifier of the fruit with the largest absolute local consistency residual.")
	@Unit("-")
	@Tags("Identifiers")
	public long maxFruitResidualOrganID;

	@JsonProperty(value = "fruitStoredVsExactResidual", index = 90)
	@JsonPropertyDescription("Signed residual sumFruitStoredUnloading minus sumFruitExactUnloading.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double fruitStoredVsExactResidual;

	@JsonProperty(value = "maxFruitTaylorPointResidual", index = 91)
	@JsonPropertyDescription("Largest absolute pure Taylor reconstruction residual when re-expanded at final fruit Phi.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double maxFruitTaylorPointResidual;

	@JsonProperty(value = "maxFruitTaylorPointRelativeResidual", index = 92)
	@JsonPropertyDescription("Largest relative pure Taylor reconstruction residual when re-expanded at final fruit Phi.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double maxFruitTaylorPointRelativeResidual;

	@JsonProperty(value = "simpleRootActive", index = 93)
	@JsonPropertyDescription("Whether this solve used the deterministic simple layered root CT route.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean simpleRootActive;

	@JsonProperty(value = "simpleRootTopologyValid", index = 94)
	@JsonPropertyDescription("Whether simple roots and fine roots form one complete linked layer chain for the plant.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean simpleRootTopologyValid;

	@JsonProperty(value = "simpleRootFoldValid", index = 95)
	@JsonPropertyDescription("Whether every simple-root layer folded once with complete structural-root and fine-root coverage.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean simpleRootFoldValid;

	@JsonProperty(value = "simpleRootUnfoldValid", index = 96)
	@JsonPropertyDescription("Whether every simple-root layer and fine root received potential exactly once.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public boolean simpleRootUnfoldValid;

	@JsonProperty(value = "simpleRootDoubleFoldCount", index = 97)
	@JsonPropertyDescription("Number of attempted second StructuralRoot resistance transforms in the same simple-root fold pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public int simpleRootDoubleFoldCount;

	@JsonProperty(value = "simpleRootMinLayer", index = 98)
	@JsonPropertyDescription("Minimum soil-layer index in the simple-root chain.")
	@Unit("layer index")
	@Tags("Identifiers")
	public int simpleRootMinLayer;

	@JsonProperty(value = "simpleRootMaxLayer", index = 99)
	@JsonPropertyDescription("Maximum soil-layer index in the simple-root chain.")
	@Unit("layer index")
	@Tags("Identifiers")
	public int simpleRootMaxLayer;

	@JsonProperty(value = "simpleRootLayerCount", index = 100)
	@JsonPropertyDescription("Number of contiguous layers expected in the simple-root chain.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public int simpleRootLayerCount;

	@JsonProperty(value = "simpleStructuralRootExpected", index = 101)
	@JsonPropertyDescription("Number of StructuralRoot objects expected in the simple-root fold and unfold.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleStructuralRootExpected;

	@JsonProperty(value = "simpleStructuralRootFolded", index = 102)
	@JsonPropertyDescription("Number of simple StructuralRoot objects transformed exactly once in the final fold pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleStructuralRootFolded;

	@JsonProperty(value = "simpleStructuralRootUnfolded", index = 103)
	@JsonPropertyDescription("Number of simple StructuralRoot objects unfolded exactly once in the final pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleStructuralRootUnfolded;

	@JsonProperty(value = "simpleFineRootExpected", index = 104)
	@JsonPropertyDescription("Number of FineRoot objects expected to contribute to the simple-root fold and unfold.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleFineRootExpected;

	@JsonProperty(value = "simpleFineRootFolded", index = 105)
	@JsonPropertyDescription("Number of same-layer FineRoot objects actually included once in the final simple-root fold pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleFineRootFolded;

	@JsonProperty(value = "simpleFineRootUnfolded", index = 106)
	@JsonPropertyDescription("Number of same-layer FineRoot objects unfolded exactly once in the final pass.")
	@Unit("count")
	@Tags("Solver diagnostics")
	public long simpleFineRootUnfolded;

	@JsonProperty(value = "simpleRootLocalJ", index = 107)
	@JsonPropertyDescription("Signed sum of local StructuralRoot and FineRoot currents in the simple-root subsystem.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double simpleRootLocalJ;

	@JsonProperty(value = "simpleRootFoldedJ", index = 108)
	@JsonPropertyDescription("Current entering the simple-root subsystem through folded layer zero at PlantBase potential.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double simpleRootFoldedJ;

	@JsonProperty(value = "simpleRootClosureResidual", index = 109)
	@JsonPropertyDescription("Signed simple-root closure residual: local root current minus folded root-entry current.")
	@Unit("g C/h")
	@Tags("Solver diagnostics")
	public double simpleRootClosureResidual;

	@JsonProperty(value = "simpleRootRelativeClosureResidual", index = 110)
	@JsonPropertyDescription("Absolute simple-root closure residual relative to the larger local or folded root current magnitude.")
	@Unit("-")
	@Tags("Solver diagnostics")
	public double simpleRootRelativeClosureResidual;
}
