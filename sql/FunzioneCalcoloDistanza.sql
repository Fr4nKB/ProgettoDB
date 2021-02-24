DROP FUNCTION IF EXISTS CalcoloDistanza;
DELIMITER $$
CREATE FUNCTION CalcoloDistanza (latA DOUBLE, lonA DOUBLE, latB DOUBLE, lonB DOUBLE)
RETURNS DOUBLE NOT DETERMINISTIC
    BEGIN
        DECLARE Raggio DOUBLE DEFAULT 6371;
        DECLARE PiGreco DOUBLE DEFAULT 3.1415927;
        DECLARE lat_a DOUBLE;
        DECLARE lat_b DOUBLE;
        DECLARE lon_a DOUBLE;
        DECLARE lon_b DOUBLE;
        DECLARE Phi DOUBLE;
        DECLARE p DOUBLE;
        DECLARE dist DOUBLE;
        SET lat_a = pigreco * latA / 180;
        SET lat_b = pigreco * latB / 180;
        SET lon_a = pigreco * lonA / 180;
        SET lon_b = pigreco * lonB / 180;
        SET Phi = ABS(lon_a - lon_b);
        SET p = acos(sin(lat_b) * sin(lat_a) + cos(lat_b) * cos(lat_a) * cos(Phi));
        SET Dist = p * R;
        RETURN Dist;
    END $$
DELIMITER ;