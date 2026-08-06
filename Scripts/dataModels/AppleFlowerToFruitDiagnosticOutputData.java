import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;
@JsonRootName("apple-flower-to-fruit-diagnostic")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppleFlowerToFruitDiagnosticOutputData implements Serializable {
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

	@JsonProperty(value = "flowerId", index = 9)
	@JsonPropertyDescription("Graph identifier of the source flower.")
	@Tags("Architecture")
	public long flowerId;

	@JsonProperty(value = "fruitId", index = 10)
	@JsonPropertyDescription("Graph identifier of the initialized fruit.")
	@Tags("Architecture")
	public long fruitId;

	@JsonProperty(value = "parentInternodeId", index = 11)
	@JsonPropertyDescription("Graph identifier of the parent internode.")
	@Tags("Architecture")
	public long parentInternodeId;

	@JsonProperty(value = "flowerBiomass", index = 12)
	@JsonPropertyDescription("Flower dry biomass immediately before fruit conversion.")
	@Unit("mg")
	@Tags("Carbon")
	public double flowerBiomass;

	@JsonProperty(value = "flowerFreshWeight", index = 13)
	@JsonPropertyDescription("Flower fresh weight immediately before fruit conversion.")
	@Unit("mg")
	@Tags("Development state")
	public double flowerFreshWeight;

	@JsonProperty(value = "flowerWaterContent", index = 14)
	@JsonPropertyDescription("Flower water-content fraction immediately before fruit conversion.")
	@Unit("-")
	@Tags("Water")
	public double flowerWaterContent;

	@JsonProperty(value = "fruitBiomassAfterInit", index = 15)
	@JsonPropertyDescription("Fruit dry biomass immediately after initialization.")
	@Unit("mg")
	@Tags("Carbon")
	public double fruitBiomassAfterInit;

	@JsonProperty(value = "fruitFreshWeightAfterInit", index = 16)
	@JsonPropertyDescription("Fruit fresh weight immediately after initialization.")
	@Unit("mg")
	@Tags("Development state")
	public double fruitFreshWeightAfterInit;

	@JsonProperty(value = "flowerAge", index = 17)
	@JsonPropertyDescription("Flower age in the active thermal-time scale.")
	@Tags("Timing")
	public double flowerAge;

	@JsonProperty(value = "flowerAgeD", index = 18)
	@JsonPropertyDescription("Flower age in days.")
	@Unit("d")
	@Tags("Timing")
	public double flowerAgeD;

	@JsonProperty(value = "ageDAtFlowering", index = 19)
	@JsonPropertyDescription("Flower day-age recorded at flowering.")
	@Unit("d")
	@Tags("Timing")
	public double ageDAtFlowering;

	@JsonProperty(value = "daysAfterBloom", index = 20)
	@JsonPropertyDescription("Elapsed days since the recorded flowering age.")
	@Unit("d")
	@Tags("Timing")
	public double daysAfterBloom;

	@JsonProperty(value = "fruitingDaysAfterBloom", index = 21)
	@JsonPropertyDescription("Configured days after bloom required for fruit conversion.")
	@Unit("d")
	@Tags("Development state")
	public double fruitingDaysAfterBloom;

	@JsonProperty(value = "FRUIT_DRY_WEIGHT", index = 22)
	@JsonPropertyDescription("Configured initial fruit dry weight.")
	@Unit("mg")
	@Tags("Development state")
	public double FRUIT_DRY_WEIGHT;

	@JsonProperty(value = "FRUIT_FRESH_WEIGHT", index = 23)
	@JsonPropertyDescription("Configured initial fruit fresh weight.")
	@Unit("mg")
	@Tags("Development state")
	public double FRUIT_FRESH_WEIGHT;

	@JsonProperty(value = "FRUIT_AGE_AFTER_FULLBLOOM", index = 24)
	@JsonPropertyDescription("Configured initial fruit age after full bloom.")
	@Unit("d")
	@Tags("Development state")
	public int FRUIT_AGE_AFTER_FULLBLOOM;

	@JsonProperty(value = "hasFlowered", index = 25)
	@JsonPropertyDescription("Whether the source flower had reached flowering.")
	@Tags("Development state")
	public boolean hasFlowered;

	@JsonProperty(value = "dropped", index = 26)
	@JsonPropertyDescription("Whether the source flower was marked as dropped.")
	@Tags("Development state")
	public boolean dropped;
}


