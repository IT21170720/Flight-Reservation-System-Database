CREATE TABLE AirplaneType (
TypeName VARCHAR(50),
MaxNumOfSeats INT NOT NULL,
Company VARCHAR(50) NOT NULL,

CONSTRAINT airtyp_pk PRIMARY KEY (TypeName)
);

CREATE TABLE Airplane (
AirplaneID VARCHAR(10),
TotalNumOfSeats INT NOT NULL,
AirName VARCHAR(50) NOT NULL,
TypeName VARCHAR(50),

CONSTRAINT airplane_pk PRIMARY KEY (AirplaneID),
CONSTRAINT airplane_fk FOREIGN KEY (TypeName) REFERENCES AirplaneType(TypeName)
);

CREATE TABLE Airport (
AirportCode VARCHAR(10),
City VARCHAR(20) NOT NULL,
Name VARCHAR(50) NOT NULL,
State VARCHAR(20) NOT NULL,

CONSTRAINT airport_pk PRIMARY KEY (AirportCode),
);

CREATE TABLE Land (
TypeName VARCHAR(50),
AirportCode VARCHAR(10),

CONSTRAINT land_pk PRIMARY KEY (TypeName,AirportCode),
CONSTRAINT land_fk1 FOREIGN KEY (TypeName) REFERENCES AirplaneType(TypeName),
CONSTRAINT land_fk2 FOREIGN KEY (AirportCode) REFERENCES Airport(AirportCode)
);

CREATE TABLE LegInstance (
Date DATE,
AvailableSeats INT NOT NULL,
AirplaneID VARCHAR(10),

CONSTRAINT legIn_pk PRIMARY KEY (Date),
CONSTRAINT legIn_fk FOREIGN KEY (AirplaneID) REFERENCES Airplane(AirplaneID)
);

CREATE TABLE Flight (
FlightNo VARCHAR(10),
ScheduleDate DATE NOT NULL,
AirlineName VARCHAR(50) NOT NULL,

CONSTRAINT flight_pk PRIMARY KEY (FlightNo),
);

CREATE TABLE FlightLeg (
LegNo VARCHAR(10),
Date DATE,
AirportCode VARCHAR(10),
FlightNo VARCHAR(10),
DepartureTime TIME NOT NULL,
ArrivalTime TIME NOT NULL,

CONSTRAINT fleg_pk PRIMARY KEY (LegNo,Date,AirportCode,FlightNo),
CONSTRAINT fleg_fk1 FOREIGN KEY (Date) REFERENCES LegInstance(Date),
CONSTRAINT fleg_fk2 FOREIGN KEY (AirportCode) REFERENCES Airport(AirportCode),
CONSTRAINT fleg_fk3 FOREIGN KEY (FlightNo) REFERENCES Flight(FlightNo),
);

CREATE TABLE Seat (
SeatNo INT,
Date DATE,
CusName VARCHAR(50) NOT NULL,
CusPhone CHAR(10) NOT NULL,

CONSTRAINT CHK_CusPhone CHECK(CusPhone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT seat_pk PRIMARY KEY (SeatNo,Date),
CONSTRAINT seat_fk FOREIGN KEY (Date) REFERENCES LegInstance(Date)
);

CREATE TABLE FlightFare (
FareCode VARCHAR(10),
FlightNo VARCHAR(10),
Amount VARCHAR(50) NOT NULL,
Restriction VARCHAR(100) NOT NULL,

CONSTRAINT fare_pk PRIMARY KEY (FareCode),
CONSTRAINT fare_fk FOREIGN KEY (FlightNo) REFERENCES Flight(FlightNo)
);


INSERT INTO AirplaneType VALUES ('Airbus', 555, 'United States Airlines Pvt.Ltd.');
INSERT INTO AirplaneType VALUES ('Transport', 650, 'United Arab Emirates Airlines Pvt.Ltd.');
INSERT INTO AirplaneType VALUES ('Jet', 20, 'Gulf Airlines Pvt.Ltd.');
INSERT INTO AirplaneType VALUES ('Boeing', 490, 'Etihad Airlines Pvt.Ltd.');

INSERT INTO Airport VALUES ('APC00001', 'New York', 'United States Airlines', 'New York');
INSERT INTO Airport VALUES ('APC00002', 'Florida', 'United States Airlines', 'Florida');
INSERT INTO Airport VALUES ('APC00003', 'Qatar', 'United Arab Emirates Airlines', 'Qatar');
INSERT INTO Airport VALUES ('APC00004', 'Abu Dhabi', 'Etihad Airlines', 'Abu Dhabi');

INSERT INTO Airplane VALUES ('AP000001', 555, 'United States Airlines','Airbus');
INSERT INTO Airplane VALUES ('AP000002', 650, 'United Arab Emirates Airlines','Transport');
INSERT INTO Airplane VALUES ('AP000003', 20, 'Gulf Airlines','Jet');
INSERT INTO Airplane VALUES ('AP000004', 490, 'Etihad Airlines','Boeing');

INSERT INTO Land VALUES ('Airbus', 'APC00001');
INSERT INTO Land VALUES ('Transport', 'APC00003');
INSERT INTO Land VALUES ('Jet', 'APC00002');
INSERT INTO Land VALUES ('Boeing', 'APC00004');

INSERT INTO LegInstance VALUES ('2022-10-11', 120, 'AP000001');
INSERT INTO LegInstance VALUES ('2022-10-12', 76, 'AP000002');
INSERT INTO LegInstance VALUES ('2022-10-13', 2, 'AP000003');
INSERT INTO LegInstance VALUES ('2022-10-14', 48, 'AP000004');

INSERT INTO Flight VALUES ('F001', '2022-10-15', 'United States Airlines');
INSERT INTO Flight VALUES ('F002', '2022-10-16', 'United States Airlines');
INSERT INTO Flight VALUES ('F003', '2022-10-17', 'United Arab Emirates Airlines');
INSERT INTO Flight VALUES ('F004', '2022-10-18', 'Etihad Airlines');

INSERT INTO FlightLeg VALUES ('FL001', '2022-10-11', 'APC00001', 'F001', '10:40:00', '14:40:00');
INSERT INTO FlightLeg VALUES ('FL002', '2022-10-12', 'APC00002', 'F002', '12:20:00', '13:30:00');
INSERT INTO FlightLeg VALUES ('FL003', '2022-10-13', 'APC00003', 'F003', '14:30:00', '16:20:00');
INSERT INTO FlightLeg VALUES ('FL004', '2022-10-14', 'APC00004', 'F004', '16:50:00', '20:20:00');

INSERT INTO Seat VALUES (1, '2022-10-11', 'Jayawikrama', '0765486592');
INSERT INTO Seat VALUES (2, '2022-10-12', 'Samaranayake', '0785469583');
INSERT INTO Seat VALUES (3, '2022-10-13', 'Siriwardana', '0720465982');
INSERT INTO Seat VALUES (4, '2022-10-14', 'Ariyarathna', '0755689321');

INSERT INTO FlightFare VALUES ('FF001', 'F001', concat('$',300.00), 'Electronic travel authorization');
INSERT INTO FlightFare VALUES ('FF002', 'F002', concat('$',350.00), 'Electronic travel authorization');
INSERT INTO FlightFare VALUES ('FF003', 'F003', concat('$',280.00), 'Visitor visa');
INSERT INTO FlightFare VALUES ('FF004', 'F004', concat('$',400.00), 'Visa is not required ');

SELECT * FROM AirplaneType
SELECT * FROM Airplane
SELECT * FROM Airport
SELECT * FROM LegInstance
SELECT * FROM Land
SELECT * FROM Flight
SELECT * FROM FlightLeg
SELECT * FROM Seat
SELECT * FROM FlightFare

--Trigger for available seats
--Trigger 1- a trigger that shall fire upon the DELETE statement on the AirplaneType table
CREATE TRIGGER delete_AirplaneType_details
ON AirplaneType 
INSTEAD OF DELETE
AS
BEGIN 
	DECLARE @tname INT;
    DECLARE @count INT;
    SELECT @tname = TypeName FROM DELETED;
    SELECT @count = COUNT(*) FROM Airplane WHERE TypeName = @tname;
    IF @count = 0
        DELETE FROM AirplaneType WHERE TypeName = @tname;
    ELSE
        THROW 56000, 'can not delete - AirplaneType is referenced in other tables', 1;
END

--Trigger 2- trigger for FlightLeg table that check before insert statement 

DROP TRIGGER IF EXISTS leg_insert_check;
GO
CREATE TRIGGER leg_insert_check ON FlightLeg INSTEAD OF INSERT
AS BEGIN
    DECLARE @l_no VARCHAR(10);
    DECLARE @date DATE;
    DECLARE @a_code  VARCHAR(10);
	DECLARE @f_no  VARCHAR(10);
	DECLARE @deptime  TIME;
	DECLARE @arrtime  TIME;

    SELECT @l_no = LegNo, @date = Date, @a_code = AirportCode, @f_no = FlightNo, @deptime = DepartureTime, @arrtime = ArrivalTime FROM INSERTED;
    IF @l_no IS NULL SET @l_no = 0;
    IF @date IS NULL SET @date = GETDATE();
    INSERT INTO FlightLeg (LegNo, Date, AirportCode, FlightNo, DepartureTime, ArrivalTime) VALUES (@l_no, @date, @a_code, @f_no, @deptime, @arrtime);
END;

--	View for airplane details
CREATE VIEW airplane_details 
AS 
	SELECT aa.TypeName, aa.MaxNumOfSeats, aa.Company, a.AirplaneID, a.AirName, l.Date, l.AvailableSeats
	FROM  Airplane a, AirplaneType aa, LegInstance l
	WHERE a.TypeName=aa.TypeName AND a.AirplaneID=l.AirplaneID;

SELECT * FROM airplane_details;

--	View for Customer details
CREATE VIEW customer_details 
AS
	SELECT s.CusName, s.CusPhone, a.AirName, a.TypeName, s.SeatNo , l.Date
	FROM Airplane a, LegInstance l, Seat s
	WHERE a.AirplaneID=l.AirplaneID AND	l.Date=s.Date;

SELECT * FROM customer_details;
--Index
--index in Seat table for Customer details
CREATE INDEX customer_details
ON Seat(CusName,CusPhone);

--index in FlightLeg table for Arrival/Departure Times
CREATE INDEX travelling_details
ON FlightLeg(ArrivalTime,DepartureTime);

--Procedures

--no1
CREATE PROCEDURE Sydney_airport_legs
AS
BEGIN
	SELECT fl.FlightNo, fl.LegNo, fl.ArrivalTime, fl.DepartureTime, fl.Date, ap.AirportCode, ap.City
	FROM Airport ap, FlightLeg fl
	WHERE ap.AirportCode=fl.AirportCode AND ap.City='Sydney';
END
EXEC Sydney_airport_legs

--no2
CREATE PROCEDURE Singapore_airlines
AS
BEGIN
	SELECT ai.AirplaneID, ai.AirName, ai.TypeName, ai.TotalNumOfSeats, ap.City
	FROM Airplane ai, Airport ap, AirplaneType aty, Land la 
	WHERE ai.TypeName=aty.TypeName AND aty.TypeName=la.TypeName AND la.AirportCode=ap.AirportCode AND ap.City='Singapore';
END
EXEC Singapore_airlines

--no3
CREATE PROCEDURE Get_Discount( @flightNo CHAR,@amount REAL,@code REAL) 
AS 
BEGIN
     
    IF @flightNo='KL203'
	UPDATE FlightFare
	SET Amount=Amount+@amount*0.20
	WHERE FareCode=@code

	ELSE
	
	UPDATE FlightFare
	SET Amount=Amount+@amount
	WHERE FareCode=@code
END	

--no4
CREATE PROCEDURE flight_taken
AS
BEGIN
	SELECT f.FlightNo, f.ScheduleDate, f.AirlineName
	FROM Seat s, Flight f, LegInstance l, FlightLeg fl
	WHERE s.Date=l.Date AND  l.Date=fl.Date AND fl.FlightNo=f.FlightNo AND s.CusName='Mary Ann';
END
