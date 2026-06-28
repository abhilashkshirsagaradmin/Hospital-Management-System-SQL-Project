-- Hospital-Management-System-SQL-Project


-- Basic Questions

-- Que 1- List patients with their appointment doctor and reason.

SELECT 
    patients.Fname AS patient_name,
    doctor.Fname AS doctor_name,
    appointment.reason
FROM
    appointment
        JOIN
    patients ON appointment.patient_Id = patients.patient_Id
        JOIN
    doctor ON doctor.doct_Id = appointment.doct_Id;
    


-- Que 2- Show nurses who have assisted in bed admissions with patient names.

SELECT 
    patients.Fname AS patient_name,
    nurse.Fname AS nurse_namne,
    BedRecords.admission_date
FROM
    BedRecords
        JOIN
    patients ON BedRecords.patient_Id = patients.patient_Id
        JOIN
    nurse ON nurse.nurse_Id = BedRecords.nurse_Id;

    
        
-- Que 3- List rooms used for surgeries, the surgeon, and the surgery type.

SELECT 
    room.room_no,
    room.room_type AS rooms,
    doctor.Fname AS surgeon,
    surgeryrecord.surgery_type
FROM
    room
        JOIN
    surgeryrecord ON room.room_no = surgeryrecord.room_no
        JOIN
    doctor ON doctor.dept_id = room.dept_id;



-- Que 4- List each department with the number of doctors assigned to it.

SELECT 
    department.dept_name, COUNT(doctor.doct_id) AS doctors
FROM
    department
        JOIN
    doctor ON department.dept_id = doctor.dept_id
GROUP BY department.dept_name
ORDER BY doctors DESC; 



-- Que 5- Show patients who had an appointment and were admitted to a bed.

SELECT 
    patients.Fname AS 'Patient name',
    appointment.appointment_id,
    appointment.appointment_date,
    bedrecords.bed_no
FROM
    Appointment
        JOIN
    patients ON patients.patient_id = Appointment.patient_id
        JOIN
    bedrecords ON bedrecords.patient_id = Appointment.patient_id
ORDER BY bed_no ASC;



--  Intermediate Questions

-- Que 6- We have a new patient for the Cardiology Ward and he/she wants a bed on a specific day.We want to find out which beds are empty in that ward on that particular day.

SELECT 
    bed.bed_no, bed.ward_no
FROM
    bed
        JOIN
    ward ON bed.ward_no = ward.ward_no
        JOIN
    department ON department.dept_id = ward.dept_id
WHERE
    dept_name = 'Cardiology'
        AND bed.bed_no NOT IN (SELECT 
            bed_no
        FROM
            bedrecords
        WHERE
            '2025-05-20' BETWEEN bedrecords.admission_Date AND bedrecords.discharge_Date);
 
 
 

 -- Que 7- There is a new virus in the city and the hospital is expecting more patients than a regular day. Management wants to see if they can manage those with the current staff or not.They want to check upcoming appointments for each department on 4 June 2025.

SELECT 
    department.dept_name,
    COUNT(appointment.appointment_id) AS total_appointments
FROM
    appointment
        JOIN
    doctor ON doctor.doct_id = appointment.doct_id
        JOIN
    department ON department.dept_id = doctor.dept_id
WHERE
    appointment.appointment_date = '2025-06-04'
GROUP BY department.dept_name;




-- Que 8- Doctors is asking for a salary raise due to extra work in the previous month. Verify if he/she deserves a raise by retrieving their total appointments, total visits, total surgeries, and total shifts.

SELECT 
    doctor.Fname AS Doctor_name,
    (SELECT 
            COUNT(*)
        FROM
            appointment
        WHERE
            appointment.doct_id = doctor.doct_id
                AND appointment.appointment_Date BETWEEN '2025-05-01' AND '2025-05-30') AS total_appointment,
    (SELECT 
            COUNT(*)
        FROM
            medicalrecord
        WHERE
            medicalrecord.doct_id = doctor.doct_id
                AND medicalrecord.visit_Date BETWEEN '2025-05-01' AND '2025-05-30') AS total_visits,
    (SELECT 
            COUNT(*)
        FROM
            surgeryrecord
        WHERE
            surgeon_id = doctor.doct_id
                AND surgeryrecord.surgery_date BETWEEN '2025-05-01' AND '2025-05-30') AS total_surgeries,
    (SELECT 
            COUNT(*)
        FROM
            staffshift
        WHERE
            staffshift.doct_id = doctor.doct_id
                AND staffshift.shift_Date BETWEEN '2025-05-01' AND '2025-05-30') AS total_shift
FROM
    doctor
ORDER BY total_shift DESC;




-- Que 9- The hospital is analyzing its daily revenue and wants to calculate the revenue generated on 10 May 2025 (including appointment revenue, room revenue, and bed revenue).

SELECT 
    SUM(appointment.payment_amount) AS appointment_rev,
    SUM(RoomRecords.amount) AS room_rev,
    SUM(BedRecords.amount) AS bed_rev,
    (SUM(appointment.payment_amount) + SUM(RoomRecords.amount) + SUM(BedRecords.amount)) AS total_rev
FROM
    appointment
        LEFT JOIN
    roomrecords ON roomrecords.admission_Date = '2025-05-10'
        LEFT JOIN
    bedrecords ON bedrecords.admission_Date = '2025-05-10'
WHERE
    appointment.appointment_Date = '2025-05-10';



-- Que 10- The hospital decided to give some discounts to its old customers on some services. Identify patients who have visited the hospital more than 4 times in the past year.

SELECT 
    patients.patient_Id,
    patients.FName,
    COUNT(medicalrecord.record_Id) AS total_visits
FROM
    patients
        JOIN
    medicalrecord ON medicalrecord.patient_Id = patients.patient_Id
WHERE
    medicalrecord.visit_Date >= '2025-01-01'
GROUP BY patients.patient_Id , patients.FName
HAVING COUNT(medicalrecord.record_Id) > '4'
ORDER BY total_visits DESC;



-- Advanced Questions

-- Que 11- Management received a report that a patient was given the wrong amount of anesthesia during surgery. Track which staff (surgeon, nurse, and helper) was present during the surgery of patient 967 on 16 May 2024 between 11 to 12 at night.

SELECT 
    patients.patient_Id,
    patients.FName AS Patiend_name,
    doctor.FName AS Surgeon_name,
    nurse.FName AS Nurse_name,
    helpers.FName AS Helper_name,
    surgeryrecord.surgery_Type,
    surgeryrecord.surgery_Date,
    surgeryrecord.start_Time,
    surgeryrecord.end_Time,
    surgeryrecord.notes
FROM
    surgeryrecord
        JOIN
    patients ON patients.patient_Id = surgeryrecord.patient_Id
        JOIN
    doctor ON doctor.doct_Id = surgeryrecord.surgeon_Id
        JOIN
    nurse ON nurse.nurse_id = surgeryrecord.nurse_id
        JOIN
    helpers ON helpers.helper_id = surgeryrecord.helper_id
WHERE
    surgeryrecord.surgery_Date = '2024-05-16'
        AND surgeryrecord.patient_Id = '967'
        AND surgeryrecord.start_Time = '23:15:52'
        AND surgeryrecord.end_Time = '23:45:52';



-- Question 12- List all patients who have a follow-up appointment due this week, based on their last next_Visit from MedicalRecord.

SELECT 
    patients.patient_Id,
    patients.FName AS Patient_name,
    MedicalRecord.visit_Date
FROM
    medicalrecord
        JOIN
    patients ON patients.patient_id = medicalrecord.patient_Id
WHERE
    medicalrecord.next_Visit IS NOT NULL
        AND medicalrecord.next_Visit BETWEEN '2025-05-01' AND '2025-05-07'
ORDER BY patient_Id ASC;



-- Que 13- Find the most preferred payment method chosen by upper-class people (defined by users of super deluxe room types).

SELECT 
    roomrecords.mode_of_payment, COUNT(*) AS Usage_count
FROM
    roomrecords
        JOIN
    room ON room.room_No = roomrecords.room_no
WHERE
    room.room_Type = 'Super Deluxe Room'
GROUP BY roomrecords.mode_of_payment
ORDER BY Usage_count DESC;



-- Que 14- The hospital wants to analyze the performance of its surgeons' surgeries. Give the percentage of stable patients as per declared in the notes after surgery.

select 
	doctor.doct_Id, doctor.FName as doctor_name,
    count(*) as total_surgeries,
    sum(case 
		when lower (surgeryrecord.notes) like '%Stable%' then 1 else 0
        end) as stable_patients,
        
        round(Cast(sum(case 
		when lower (surgeryrecord.notes) like '%Stable%' then 1 else 0
        end) as float)/ count(surgeryrecord.surgery_Id)*100,2)
		as stable_percent
from  surgeryrecord
join doctor on doctor.doct_id =surgeryrecord.surgeon_Id
group by   	doctor.doct_Id, doctor.FName
order by stable_percent desc;


	    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        