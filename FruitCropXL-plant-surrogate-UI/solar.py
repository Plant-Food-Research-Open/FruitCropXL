"""
solar.py
--------
Pure-Python solar position calculator using Spencer (1971) equations.
No external dependencies beyond the Python standard library.

Returns solar elevation and azimuth (meteorological convention:
0=North, 90=East, 180=South, 270=West).

Source: Chris Van Houtte, Plant & Food Research.
"""

import math


def _day_angle_rad(day_of_year: int) -> float:
    """Day angle (radians) — Spencer (1971), eq. 1"""
    return (2.0 * math.pi / 365.0) * (day_of_year - 1)


def _equation_of_time_minutes(B: float) -> float:
    """Equation of time (minutes) — Spencer (1971), eq. 3"""
    return 229.18 * (
        0.000075
        + 0.001868 * math.cos(B)
        - 0.032077 * math.sin(B)
        - 0.014615 * math.cos(2.0 * B)
        - 0.04089 * math.sin(2.0 * B)
    )


def _solar_declination_rad(B: float) -> float:
    """Solar declination (radians) — Spencer (1971), eq. 2"""
    return (
        0.006918
        - 0.399912 * math.cos(B)
        + 0.070257 * math.sin(B)
        - 0.006758 * math.cos(2.0 * B)
        + 0.000907 * math.sin(2.0 * B)
        - 0.002697 * math.cos(3.0 * B)
        + 0.001480 * math.sin(3.0 * B)
    )


def _lon_correction_hours(lon_deg: float) -> float:
    """Within-timezone longitude offset (hours), consistent with solar_position."""
    tz_meridian = round(lon_deg / 15.0) * 15.0
    return (lon_deg - tz_meridian) / 15.0


def solar_position(
    day_of_year: int,
    hour_of_day: float,
    lat_deg: float,
    lon_deg: float,
) -> tuple:
    """
    Compute solar elevation and azimuth for a given location and time.

    Uses Spencer (1971) equations for the equation of time and solar
    declination, and standard hour-angle based formulae for elevation
    and azimuth.

    Parameters
    ----------
    day_of_year : int
        Day of year (1-365/366).
    hour_of_day : float
        Local clock time in hours (0-23.999).  A longitude-based
        correction (equation of time) converts it to true solar time.
    lat_deg : float
        Latitude in decimal degrees (negative = southern hemisphere).
    lon_deg : float
        Longitude in decimal degrees (negative = west of Greenwich).

    Returns
    -------
    (elevation_deg, azimuth_deg) : tuple[float, float]
        elevation_deg : solar elevation above horizon (degrees).
            Negative values mean the sun is below the horizon.
        azimuth_deg   : solar azimuth, meteorological convention
            (0 = North, 90 = East, 180 = South, 270 = West), degrees.
    """

    # ------------------------------------------------------------------
    # 1. Day angle (radians) — Spencer (1971), eq. 1
    # ------------------------------------------------------------------
    B = _day_angle_rad(day_of_year)

    # ------------------------------------------------------------------
    # 2. Equation of time (minutes) — Spencer (1971), eq. 3
    # ------------------------------------------------------------------
    eot_minutes = _equation_of_time_minutes(B)

    # ------------------------------------------------------------------
    # 3. Solar declination (radians) — Spencer (1971), eq. 2
    # ------------------------------------------------------------------
    decl_rad = _solar_declination_rad(B)

    # ------------------------------------------------------------------
    # 4. True solar time (hours)
    #    hour_of_day is assumed to be LOCAL STANDARD TIME.
    #    Apply only the within-timezone longitude offset (not the full UTC
    #    offset), so the caller does not need to know the UTC offset.
    # ------------------------------------------------------------------
    lon_correction_hours = _lon_correction_hours(lon_deg)
    true_solar_time = hour_of_day + lon_correction_hours + eot_minutes / 60.0

    # ------------------------------------------------------------------
    # 5. Hour angle (radians)
    #    Solar noon => hour angle = 0; +15 deg per hour east of solar noon.
    # ------------------------------------------------------------------
    hour_angle_deg = 15.0 * (true_solar_time - 12.0)
    hour_angle_rad = math.radians(hour_angle_deg)

    lat_rad = math.radians(lat_deg)

    # ------------------------------------------------------------------
    # 6. Solar elevation (altitude) angle
    #    sin(elev) = sin(lat)*sin(decl) + cos(lat)*cos(decl)*cos(HA)
    # ------------------------------------------------------------------
    sin_elev = (
        math.sin(lat_rad) * math.sin(decl_rad)
        + math.cos(lat_rad) * math.cos(decl_rad) * math.cos(hour_angle_rad)
    )
    sin_elev = max(-1.0, min(1.0, sin_elev))
    elev_rad = math.asin(sin_elev)
    elev_deg = math.degrees(elev_rad)

    # ------------------------------------------------------------------
    # 7. Solar azimuth — atan2 formulation (correct quadrant, no acos flip)
    #    az_astro (0=South, +East) via atan2, then → met (0=North, +East)
    # ------------------------------------------------------------------
    cos_elev = math.cos(elev_rad)

    if abs(cos_elev) < 1e-9:
        az_met = 0.0  # zenith — azimuth undefined, default to North
    else:
        az_astro_rad = math.atan2(
            math.sin(hour_angle_rad),
            math.sin(lat_rad) * math.cos(hour_angle_rad)
            - math.cos(lat_rad) * math.tan(decl_rad),
        )
        # az_astro: 0=South, +East (positive morning, negative afternoon)
        # → meteorological: 0=North, 90=East
        az_met = (math.degrees(az_astro_rad) + 180.0) % 360.0

    return elev_deg, az_met


def sunrise_sunset(
    day_of_year: int,
    lat_deg: float,
    lon_deg: float,
) -> tuple:
    """
    Compute sunrise and sunset as local clock time (decimal hours) for a
    given day and location, using the same Spencer (1971) declination and
    longitude/timezone handling as solar_position().

    Standard hour-angle formula: cos(H) = -tan(lat)*tan(decl), where H is
    the half-day length in radians. Sunrise/sunset in true solar time are
    12 -+ H*12/pi; these are then converted back to local clock time by
    inverting the same longitude/equation-of-time offset that
    solar_position() applies when going from clock time to true solar time.

    Parameters
    ----------
    day_of_year : int
        Day of year (1-365/366).
    lat_deg : float
        Latitude in decimal degrees (negative = southern hemisphere).
    lon_deg : float
        Longitude in decimal degrees (negative = west of Greenwich).

    Returns
    -------
    (sunrise_hr, sunset_hr) : tuple[float | None, float | None]
        Local clock time of sunrise and sunset, in decimal hours.
        (None, None) if the sun never rises/sets that day at that
        latitude (polar day or polar night) — the caller decides the
        fallback behaviour for that case.
    """
    B = _day_angle_rad(day_of_year)
    eot_minutes = _equation_of_time_minutes(B)
    decl_rad = _solar_declination_rad(B)

    lat_rad = math.radians(lat_deg)
    cos_hour_angle = -math.tan(lat_rad) * math.tan(decl_rad)

    if abs(cos_hour_angle) > 1.0:
        return None, None

    half_day_rad = math.acos(cos_hour_angle)

    sunrise_solar = 12.0 - half_day_rad * 12.0 / math.pi
    sunset_solar = 12.0 + half_day_rad * 12.0 / math.pi

    # Invert the clock-time -> true-solar-time offset used in solar_position().
    offset_hours = _lon_correction_hours(lon_deg) + eot_minutes / 60.0
    sunrise_hr = sunrise_solar - offset_hours
    sunset_hr = sunset_solar - offset_hours

    return sunrise_hr, sunset_hr
