import java.io.Serializable;

/**
 * Backend-independent light-interception result for a leaf, fruit,
 * or soil tile.
 *
 * This is a transient calculation result. It is not an output-table DTO
 * and does not own persistent plant or field state.
 */
public final class LightInterceptionResult implements Serializable {

	private static final long serialVersionUID = 1L;

	/** Incident PAR on the target surface (umol m-2 s-1). */
	public double incPARm2;

	/** Total PAR absorbed by the target (umol s-1). */
	public double absPAR;

	/** Total far-red radiation absorbed by the target (umol s-1). */
	public double absFarRed;

	/** Total absorbed radiation represented by the backend (umol s-1). */
	public double abs;

	/** Total absorbed radiation per target area (umol m-2 s-1). */
	public double absm2;

	/** Absorbed PAR per target area (umol m-2 s-1). */
	public double absPARm2;

	/** Relative incident PAR using the existing FruitCropXL definition. */
	public double fpar;

	/** Relative total absorbed radiation using the existing definition. */
	public double fabs;

	/**
	 * Returns a result whose numerical fields are all explicitly zero.
	 */
	public static LightInterceptionResult zero() {
		return new LightInterceptionResult();
	}
}
