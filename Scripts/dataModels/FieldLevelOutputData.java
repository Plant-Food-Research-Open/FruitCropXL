import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonRootName;
import io.github.fruitcropxl.output.annotation.Tags;
import io.github.fruitcropxl.output.annotation.Unit;
import java.io.Serializable;

@JsonRootName("field-level")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class FieldLevelOutputData implements Serializable {

  @JsonProperty(value = "timestamp", index = 0)
  @JsonPropertyDescription("Time-stamp in ISO 8601 format")
  @Tags("Time and identifier")
  public String timestamp;

  @JsonProperty(value = "year", index = 1)
  @JsonPropertyDescription("year")
  public int year;

  @JsonProperty(value = "dayOfYear", index = 2)
  @JsonPropertyDescription("Day of year ")
  public int dayOfYear;

  @JsonProperty(value = "hourOfDay", index = 3)
  @JsonPropertyDescription("Hour of day")
  public int hourOfDay;

  @JsonProperty(value = "latitude", index = 4)
  @JsonPropertyDescription(
    "The latitude of the place in degrees, based on the convention that use North as positive, South is negative."
  )
  public float latitude;

  @JsonProperty(value = "longitude", index = 5)
  @JsonPropertyDescription(
    "The longitude in degrees, based on the convention use East as positive and West as negative"
  )
  public float longitude;

  @JsonProperty(value = "rowDistance", index = 6)
  @JsonPropertyDescription("Distance between rows.")
  public double rowDistance;

  @JsonProperty(value = "plantDistance", index = 7)
  @JsonPropertyDescription("Distance between plants in a row.")
  public double plantDistance;

  @JsonProperty(value = "rowOrientation", index = 8)
  @JsonPropertyDescription(
    "Row orientation. 0 is for east-west, 90 is for south-north (rotate counter-clockwise)."
  )
  public float rowOrientation;

  @JsonProperty(value = "scenario", index = 9)
  @JsonPropertyDescription(
    "Internal sub-scenario number for configure different simulations"
  )
  public int scenario;

  @JsonProperty(value = "age_degreeDay", index = 10)
  @JsonPropertyDescription(
    "Represents the main organ age in terms of effective growing days adjusted for temperature effects."
  )
  public double age_degreeDay;

  @JsonProperty(value = "age_days", index = 11)
  @JsonPropertyDescription("Represents the organ age in days")
  public float age_days;

  @JsonProperty(value = "incomingRadiation", index = 12)
  @JsonPropertyDescription(
    "Rate of solar radiation received per unit area, measured in micromoles of photons per square meter per second."
  )
  @Unit("umol/m²/s")
  public double incomingRadiation;

  @JsonProperty(value = "azimuth", index = 13)
  public double azimuth;

  @JsonProperty(value = "zenith", index = 14)
  public double zenith;

  @JsonProperty(value = "solarElevation", index = 15)
  public double solarElevation;

  @JsonProperty(value = "leafAreaPerPlant", index = 16)
  @JsonPropertyDescription("Mean leaf area per vine.")
  @Unit("m²")
  public double leafAreaPerPlant;

  @JsonProperty(value = "LAI", index = 17)
  @JsonPropertyDescription("Leaf Area Index (LAI) of the field.")
  public double LAI;

  @JsonProperty(value = "hourlyAbsorbedRadiation", index = 18)
  @JsonPropertyDescription("Canopy absorbed radiation")
  @Unit("umol/m²/s")
  public double hourlyAbsorbedRadiation;

  @JsonProperty(value = "fabsPlant", index = 19)
  @JsonPropertyDescription(
    "Plant-level absorbed total-radiation fraction aggregated into the field-level output."
  )
  public double fabsPlant;

  @JsonProperty(value = "fparPlant", index = 20)
  @JsonPropertyDescription(
    "Plant-level absorbed PAR fraction aggregated into the field-level output."
  )
  public double fparPlant;
  
  
  @JsonProperty(value = "fabsSoil", index = 21)
  @JsonPropertyDescription(
    "Field-level light condition: fraction of global radiation absorbed by soil represented by the Tile module"
  )
  public double fabsSoil;

  @JsonProperty(value = "fparSoil", index = 22)
  @JsonPropertyDescription(
    "Field-level light condition: fraction of PAR absorbed by soil represented by the Tile module"
  )
  public double fparSoil;
  
  @JsonProperty(value = "fparGround", index = 23)
  @JsonPropertyDescription(
    "Fraction of PAR penetrated to the ground in the area defined by the row and plant distance. Similar to fparSoil. Depends on whether using shading factor. It is either using the fpar reached to the tile, or estimated by 1 - 1.06*fpar plant"
  )
  public double fparGround;
  
  @JsonProperty(value = "k", index = 24)
  @JsonPropertyDescription(
    "Light extinction coefficient for Lambert-Beer equation based on fparGround."
  )
  public double k;

  @JsonProperty(value = "k_ground", index = 25)
  @JsonPropertyDescription(
    "Light extinction coefficient for Lambert-Beer equation based on field base LAI and fparGround"
  )
  public double k_ground;
  
  @JsonProperty(value = "fPARLow", index = 26)
  @JsonPropertyDescription(
    "Fraction of PAR penetrated to low layer leaves, trunk height to 1/3 of the plant height - trunk height."
  )
  public double fPARLow;

  @JsonProperty(value = "fPARMid", index = 27)
  @JsonPropertyDescription(
    "Fraction of PAR penetrated to mid layer leaves, 1/3 to 2/3 of the plant height - trunk height"
  )
  public double fPARMid;

  @JsonProperty(value = "fPARUp", index = 28)
  @JsonPropertyDescription(
    "Fraction of PAR penetrated to upper layer leaves, 2/3 of the canopy height. to the plant height."
  )
  public double fPARUp;

  @JsonProperty(value = "fPARGlobal", index = 29)
  public double fPARGlobal;

  @JsonProperty(value = "fDiffuseLight", index = 30)
  public double fDiffuseLight;
  
  @JsonProperty(value = "plantDensity", index = 31)
  @JsonPropertyDescription(
    "The plant density of the simulation."
  )
  public double plantDensity;
  
  @JsonProperty(value = "simuuid", index = 32)
  @JsonPropertyDescription("The unique simulation UUID assigned to each simulation run.")
  public String simuuid;



}
