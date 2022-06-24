import express from "express";
import session from 'express-session';
import dateFormat, { masks } from "dateformat";
import upload from 'express-fileupload'
import path from 'path';
import bodyParser from 'body-parser';
import { fileURLToPath } from 'url';
import { createConnection } from "mysql2";
import { SearchUser, GetUser, GetEmployee } from "./ServerDB.js"

var User = "";
Date.prototype.addDays = function(days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}
Date.prototype.addMinutes = function (minutes) {
    return new Date(this.getTime() + minutes*60000);
}

const urlencodedParser = express.urlencoded({ extended: true });
const conn = createConnection({
    host: "localhost",
	port: 3306,
    user: "root",
    database: "diplom",
    password: "root"
});
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();

app.set("view engine", "hbs");

app.use(express.static(__dirname + "\\View"));
app.use(session({
    secret: 'you secret key',
    saveUninitialized: true,
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(upload());

app.get("/vhod", function (req, res) {
    res.render(__dirname + "\\View\\" + "vhod.hbs");
});

app.post("/vhod", urlencodedParser, function (req, res) {
    if (!req.body) return res.sendStatus(400);

    const Login = req.body.login;
    const Password = req.body.password;
    GetUser(Login, function (result) {
		if (result[0] == undefined){
            return res.send("<a href=\"/\">Такого пользователя нет</a>")
        }
        if (result[0].Password != Password) {
            res.redirect("/vhod");
        }
        else {
            req.session.User = result[0];
            if (result[0].UserType == 'Сотрудник') {
                GetEmployee(Login, function (result) {
                    if (result[0].PositionName == "Медсестра") {
                        res.redirect("/medsismain");
                    }
                    else {
                        res.redirect("/employeemain");
                    }
                })
            }
            else if (result[0].UserType == 'Пациент') {
                res.redirect("/patientmain");
            }
        }
    });
});

app.get("/medsismain", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        res.render(__dirname + "\\View\\medsister\\" + "medsis_main.hbs", {
            Name: req.session.User.Name,
            Surname: req.session.User.Surname,
            Patornymic: req.session.User.Patronymic,
            Photo: "/UserImg/" + req.session.User.Photo
        });
    }
});

app.get("/medsisnewpatient", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        res.render(__dirname + "\\View\\medsister\\" + "medsis_new_patient.hbs", {
            Name: req.session.User.Name,
            Surname: req.session.User.Surname,
            Patornymic: req.session.User.Patronymic
        });
    }
});

app.post("/medsisnewpatient", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        const Name = req.body.name;
        const Surname = req.body.surname;
        const Patronymic = req.body.patronymic;
        const Address = req.body.adress;
        const Passport = req.body.passport;
        const MedicalPolicy = req.body.medpolice;
        const BookId = 1;
        const Login = req.body.login;
        const Password = req.body.password;
        const Phone = req.body.telephone;
        let Photo = "";
        if (req.files) {
            let avatar = req.files.file;
            Photo = Name + Surname + Patronymic + Login + avatar.name;
            avatar.mv('Server/View/UserImg/' + Photo);
        }
        GetUser(Login, function (result) {
            if (result.length != 0) {
                return res.send("Пользователь уже существует");
            }
            else {
                conn.query("INSERT INTO user (Login, Password, Name, Surname, Patronymic, Phone, Photo, UserType) VALUES (?,?,?,?,?,?,?,?)",
                    [Login, Password, Name, Surname, Patronymic, Phone, Photo, "Пациент"], function (err, data) {
                        if (err) return console.log(err);
                        conn.query("INSERT INTO patient (Login, Address, Passport, MedicalPolicy, BookId) VALUES (?,?,?,?,?)",
                            [Login, Address, Passport, MedicalPolicy, BookId], function (err, data) {
                                if (err) return console.log(err);
                                res.redirect("/");
                            });
                    });

            }
        })
    }
});

app.get("/medsisnewdoctor", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        conn.query("SELECT * FROM position", function (err, data) {
            if (err) return console.log(err);
            console.log(data);
            res.render(__dirname + "\\View\\medsister\\" + "medsis_new_doctor.hbs", {
                name: req.session.User.Name,
                surname: req.session.User.Surname,
                patornymic: req.session.User.Patronymic,
                Positions: data
            });
        });
    }
});

app.post("/medsisnewdoctor", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        const Name = req.body.name;
        const Surname = req.body.surname;
        const Patronymic = req.body.patronymic;
        const Login = req.body.login;
        const Password = req.body.password;
        const Phone = req.body.telephone;
        const Positions = req.body.positions;
        let Photo = "";
        if (req.files) {
            let avatar = req.files.file;
            Photo = Name + Surname + Patronymic + Login + avatar.name;
            avatar.mv('Server/View/UserImg/' + Photo);
        }
        GetUser(Login, function (result) {
            if (result.length != 0) {
                return res.send("Пользователь уже существует");
            }
            else {
                conn.query("INSERT INTO user (Login, Password, Name, Surname, Patronymic, Phone, Photo, UserType) VALUES (?,?,?,?,?,?,?,?)",
                    [Login, Password, Name, Surname, Patronymic, Phone, Photo, "Сотрудник"], function (err, data) {
                        if (err) return console.log(err);
                        conn.query("INSERT INTO employee (Login, PositionName) VALUES (?,?)",
                            [Login, Positions], function (err, data) {
                                if (err) return console.log(err);
                                res.redirect("/");
                            });
                    });

            }
        })
    }
});

app.get("/medsisentry", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let DateTime = [];
        
        const d = new Date();
        let dayWeek = d.getDay();
        let startData = new Date();
        if(dayWeek > 4){
            startData = startData.addDays(-(4 - dayWeek));
        }
        else{
            if(startData.getHours() >= 21){
                startData = startData.addDays(1);
                if(startData.getDay() > 4){
                    startData = startData.addDays(-(4 - dayWeek));
                }
                startData.setHours(9, 0, 0, 0);
            }
            else if(startData.getHours() < 9){
                startData.setHours(9, 0, 0, 0);
            }
            else{
                if(startData.getMinutes() < 30){
                    startData.setHours(startData.getHours(), 30, 0, 0);
                }
                else{
                    startData.setHours(startData.getHours() + 1, 0, 0, 0);
                    if(startData.getHours() >= 21){
                        startData = startData.addDays(1);
                        if(startData.getDay() > 4){
                            startData = startData.addDays(-(4 - dayWeek));
                        }
                        startData.setHours(9, 0, 0, 0);
                    }
                } 
            }
        }
        
        for (let index = 0; index < 5; index++) {
            if(index != 0){
                startData.setHours(9, 0, 0, 0);
            }
            let myToString = function (number) {
                return number.toLocaleString('en-US', {
                    minimumIntegerDigits: 2,
                    useGrouping: false
                });
            }
            
            let Date = myToString(startData.getDate()) + "." + myToString(startData.getMonth());
            let Times = [];
            while (startData.getHours() < 21) {
                Times.push({Time: myToString(startData.getHours()) + ":" + myToString(startData.getMinutes()), DateObject: (startData.toISOString().split('T')[0] + '+' + startData.toTimeString().split(' ')[0])});
                startData = startData.addMinutes(30);
            }
            startData = startData.addDays(1);
            dayWeek = startData.getDay();
            if(dayWeek > 4){
                startData = startData.addDays(-(4 - dayWeek));
            }
            DateTime.push({Date: Date, Times: Times});
        }

        conn.query("SELECT Name, Surname, Patronymic, PositionName, user.Login FROM user JOIN employee ON user.Login = employee.Login WHERE PositionName != ?",
            ["Медсестра"], function (err, employee_data) {
                if (err) return console.log(err);
                let all_emploee = new Map();
                employee_data.forEach(employee => {
                    if (!all_emploee.has(employee.PositionName)) {
                        all_emploee.set(employee.PositionName, []).get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                    else {
                        all_emploee.get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                });
                conn.query("SELECT Name, Surname, Patronymic, user.Login FROM user JOIN patient ON user.Login = patient.Login", function (err, patient_data) {
                    if (err) return console.log(err);
                    res.render(__dirname + "\\View\\medsister\\" + "medsis_entry.hbs", {
                        Name: req.session.User.Name,
                        Surname: req.session.User.Surname,
                        Patornymic: req.session.User.Patronymic,
                        Positions: all_emploee,
                        Patients: patient_data,
                        DateTime: DateTime
                    });
                });
            });
    }
});

app.post("/medsisentry", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        let DataTime = req.body.time.replace("+", " ");
        let EmployeeID = req.body.doctor;
        let PatientID = req.body.patient;
        let ReceptionID = null;
        let StatusID = "Назначен";

        conn.query("INSERT INTO recording (DateTime, EmployeeID, PatientID, ReceptionID, StatusID) VALUES (?,?,?,?,?)",
            [DataTime, EmployeeID, PatientID, ReceptionID, StatusID], function (err, data) {
                if (err) return console.log(err);
                res.redirect("/");
            })

    }
});

app.get("/patientmain", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        conn.query("SELECT * FROM patient WHERE Login = ?", [req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            if (result.length != 0) {
                res.render(__dirname + "\\View\\patient\\" + "patient_main.hbs", {
                    Name: req.session.User.Name,
                    Surname: req.session.User.Surname,
                    Patornymic: req.session.User.Patronymic,
                    Photo: "/UserImg/" + req.session.User.Photo,
                    Phone: req.session.User.Phone,

                    Passport: result[0].Passport,
                    Address: result[0].Address,
                    MedicalPolicy: result[0].MedicalPolicy
                });
            }
            else {
                res.send("У пользователя нет доп. данных");
            }
        });
    }
});

app.get("/employeemain", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        conn.query("SELECT * FROM employee WHERE Login = ?", [req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            if (result.length != 0) {
                res.render(__dirname + "\\View\\employee\\" + "employee_main.hbs", {
                    Name: req.session.User.Name,
                    Surname: req.session.User.Surname,
                    Patornymic: req.session.User.Patronymic,
                    Photo: "/UserImg/" + req.session.User.Photo,
                    Phone: req.session.User.Phone,
                    Position: result[0].PositionName,
                });
            }
            else {
                res.send("У пользователя нет доп. данных");
            }
        });
    }
});

let sqlrecording = "SELECT\
    ID,\
    DateTime,\
    StatusID,\
    patient.Name AS pName,\
    patient.Surname AS pSurname,\
    patient.Patronymic AS pPatronymic,\
    employee.Name AS eName,\
    employee.Surname AS eSurname,\
    employee.Patronymic AS ePatronymic,\
    moreemployee.PositionName\
    FROM\
    recording\
    JOIN user AS patient ON patient.Login = recording.PatientID\
    JOIN user AS employee ON employee.Login = recording.EmployeeID\
    JOIN employee as moreemployee ON moreemployee.Login = recording.EmployeeID\ "

app.get("/medsisfuturevisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let sql = sqlrecording +
            "ORDER BY\
            DateTime;"

        conn.query(sql, function (err, result) {
            if (err) return console.log(err);
            let Card = []
            result.forEach(el => Card.push({
                ID: el.ID,
                StatusID: el.StatusID,
                DataTiem: dateFormat(el.DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: el.pName,
                pSurname: el.pSurname,
                pPatronymic: el.pPatronymic,
                eName: el.eName,
                eSurname: el.eSurname,
                ePatronymic: el.ePatronymic,
                PositionName: el.PositionName
            }));
            res.render(__dirname + "\\View\\medsister\\" + "medsis_future_visit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                Card: Card
            });
        });
    }
});

app.post("/changestatus", function (req, res) {
    if (!req.body) return res.sendStatus(400);
    let sql = "UPDATE\
    recording\
    SET\
    StatusID = ?\
    WHERE\
    ID = ?;";

    conn.query(sql, [req.body.Status, req.body.ID], function (err, result) {
        if (err) return console.log(err);
        return res.sendStatus(200);
    });
});

app.get("/lastvisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let sql = sqlrecording +
            "WHERE\
            StatusID = ? AND patient.Login = ?\
            ORDER BY\
            DateTime;";


        conn.query(sql, ["Окончен", req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            let Card = []
            result.forEach(el => Card.push({
                ID: el.ID,
                StatusID: el.StatusID,
                DataTiem: dateFormat(el.DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: el.pName,
                pSurname: el.pSurname,
                pPatronymic: el.pPatronymic,
                eName: el.eName,
                eSurname: el.eSurname,
                ePatronymic: el.ePatronymic,
                PositionName: el.PositionName
            }));
            res.render(__dirname + "\\View\\patient\\" + "lastvisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                Card: Card
            });
        });
    }
});

app.post("/lastvisit", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        req.session.recordID = Number(req.body.ID);
        res.redirect("/lastcardvisit");
    }
});

app.get("/futurevisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let sql = sqlrecording +
            "WHERE\
            StatusID = ? AND patient.Login = ?\
            ORDER BY\
            DateTime;";


        conn.query(sql, ["Назначен", req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            let Card = []
            result.forEach(el => Card.push({
                ID: el.ID,
                StatusID: el.StatusID,
                DataTiem: dateFormat(el.DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: el.pName,
                pSurname: el.pSurname,
                pPatronymic: el.pPatronymic,
                eName: el.eName,
                eSurname: el.eSurname,
                ePatronymic: el.ePatronymic,
                PositionName: el.PositionName
            }));
            res.render(__dirname + "\\View\\patient\\" + "futurevisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                Card: Card
            });
        });
    }
});

app.get("/entry", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let DateTime = [];
        
        const d = new Date();
        let dayWeek = d.getDay();
        let startData = new Date();
        if(dayWeek > 4){
            startData = startData.addDays(-(4 - dayWeek));
        }
        else{
            if(startData.getHours() >= 21){
                startData = startData.addDays(1);
                if(startData.getDay() > 4){
                    startData = startData.addDays(-(4 - dayWeek));
                }
                startData.setHours(9, 0, 0, 0);
            }
            else if(startData.getHours() < 9){
                startData.setHours(9, 0, 0, 0);
            }
            else{
                if(startData.getMinutes() < 30){
                    startData.setHours(startData.getHours(), 30, 0, 0);
                }
                else{
                    startData.setHours(startData.getHours() + 1, 0, 0, 0);
                    if(startData.getHours() >= 21){
                        startData = startData.addDays(1);
                        if(startData.getDay() > 4){
                            startData = startData.addDays(-(4 - dayWeek));
                        }
                        startData.setHours(9, 0, 0, 0);
                    }
                } 
            }
        }
        
        for (let index = 0; index < 5; index++) {
            if(index != 0){
                startData.setHours(9, 0, 0, 0);
            }
            let myToString = function (number) {
                return number.toLocaleString('en-US', {
                    minimumIntegerDigits: 2,
                    useGrouping: false
                });
            }
            
            let Date = myToString(startData.getDate()) + "." + myToString(startData.getMonth());
            let Times = [];
            while (startData.getHours() < 21) {
                Times.push({Time: myToString(startData.getHours()) + ":" + myToString(startData.getMinutes()), DateObject: (startData.toISOString().split('T')[0] + '+' + startData.toTimeString().split(' ')[0])});
                startData = startData.addMinutes(30);
            }
            startData = startData.addDays(1);
            dayWeek = startData.getDay();
            if(dayWeek > 4){
                startData = startData.addDays(-(4 - dayWeek));
            }
            DateTime.push({Date: Date, Times: Times});
        }

        conn.query("SELECT Name, Surname, Patronymic, PositionName, user.Login FROM user JOIN employee ON user.Login = employee.Login WHERE PositionName != ?",
            ["Медсестра"], function (err, employee_data) {
                if (err) return console.log(err);
                let all_emploee = new Map();
                employee_data.forEach(employee => {
                    if (!all_emploee.has(employee.PositionName)) {
                        all_emploee.set(employee.PositionName, []).get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                    else {
                        all_emploee.get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                });

                res.render(__dirname + "\\View\\patient\\" + "entry.hbs", {
                    Name: req.session.User.Name,
                    Surname: req.session.User.Surname,
                    Patornymic: req.session.User.Patronymic,
                    Positions: all_emploee,
                    DateTime: DateTime
                });
            });
    }
});

app.post("/entry", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {

        let date = new Date();
        let DataTime = req.body.time.replace("+", " ");
        let EmployeeID = req.body.doctor;
        let PatientID = req.session.User.Login;
        let ReceptionID = null;
        let StatusID = "Назначен";

        conn.query("INSERT INTO recording (DateTime, EmployeeID, PatientID, ReceptionID, StatusID) VALUES (?,?,?,?,?)",
            [DataTime, EmployeeID, PatientID, ReceptionID, StatusID], function (err, data) {
                if (err) return console.log(err);
                res.redirect("/");
            })
    }
});

app.get("/doctorlastvisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let sql = sqlrecording +
            "WHERE\
            StatusID = ? AND employee.Login = ?\
            ORDER BY\
            DateTime;";


        conn.query(sql, ["Окончен", req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            let Card = []
            result.forEach(el => Card.push({
                ID: el.ID,
                StatusID: el.StatusID,
                DataTiem: dateFormat(el.DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: el.pName,
                pSurname: el.pSurname,
                pPatronymic: el.pPatronymic,
                eName: el.eName,
                eSurname: el.eSurname,
                ePatronymic: el.ePatronymic,
                PositionName: el.PositionName
            }));
            res.render(__dirname + "\\View\\employee\\" + "doctorlastvisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                Card: Card
            });
        });
    }
});

app.post("/doctorlastvisit", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        req.session.recordID = Number(req.body.ID);
        res.redirect("/lastcardvisit");
    }
});

app.get("/lastcardvisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let ID = req.session.recordID;
        let sql = "SELECT\
        recording.ID,\
        DateTime,\
        StatusID,\
        patient.Name AS pName,\
        patient.Surname AS pSurname,\
        patient.Patronymic AS pPatronymic,\
        reception.ID as receptionID,\
        reception.Diagnosis,\
        reception.Medication,\
        reception.Clarification\
        FROM\
        recording\
        JOIN user AS patient ON patient.Login = recording.PatientID\
        JOIN reception ON reception.ID = recording.ReceptionID\
        WHERE\
        recording.ID = ?\
        ORDER BY\
        DateTime;";

        conn.query(sql, [ID], function (err, result) {
            if (err) return console.log(err);
            res.render(__dirname + "\\View\\employee\\" + "doctorlastcardvisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                ID: result[0].ID,
                StatusID: result[0].StatusID,
                DataTiem: dateFormat(result[0].DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: result[0].pName,
                pSurname: result[0].pSurname,
                pPatronymic: result[0].pPatronymic,
                Diagnosis: result[0].Diagnosis,
                Clarification: result[0].Clarification,
                Medication: result[0].Medication
            });
        });
    }
});

app.get("/doctorfuturevisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let sql = sqlrecording +
            "WHERE\
            StatusID = ? AND employee.Login = ?\
            ORDER BY\
            DateTime;";


        conn.query(sql, ["Назначен", req.session.User.Login], function (err, result) {
            if (err) return console.log(err);
            let Card = []
            result.forEach(el => Card.push({
                ID: el.ID,
                StatusID: el.StatusID,
                DataTiem: dateFormat(el.DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: el.pName,
                pSurname: el.pSurname,
                pPatronymic: el.pPatronymic,
                eName: el.eName,
                eSurname: el.eSurname,
                ePatronymic: el.ePatronymic,
                PositionName: el.PositionName
            }));
            res.render(__dirname + "\\View\\employee\\" + "doctorfuturevisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                Card: Card
            });
        });
    }
});

app.post("/doctorfuturevisit", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        req.session.recordID = Number(req.body.ID);
        res.redirect("/doctorcardvisit");
    }
});

app.get("/doctorcardvisit", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let ID = req.session.recordID;
        let sql = sqlrecording +
            "WHERE\
            ID = ?\
            ORDER BY\
            DateTime;";

        conn.query(sql, [ID], function (err, result) {
            if (err) return console.log(err);
            res.render(__dirname + "\\View\\employee\\" + "doctorcardvisit.hbs", {
                Name: req.session.User.Name,
                Surname: req.session.User.Surname,
                Patornymic: req.session.User.Patronymic,
                ID: result[0].ID,
                StatusID: result[0].StatusID,
                DataTiem: dateFormat(result[0].DateTime, "dd.mm.yyyy HH:MM:ss"),
                pName: result[0].pName,
                pSurname: result[0].pSurname,
                pPatronymic: result[0].pPatronymic,
                eName: result[0].eName,
                eSurname: result[0].eSurname,
                ePatronymic: result[0].ePatronymic,
                PositionName: result[0].PositionName
            });
        });
    }
});

app.post("/doctorcardvisit", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        let recordID = req.session.recordID;
        conn.query("INSERT INTO reception (Diagnosis, Medication, Clarification) VALUES (?,?,?)",
            [req.body.diagnosis, req.body.medication, req.body.clarification], function (err, data) {
                if (err) return console.log(err);
                let id = data.insertId;
                let sql = "UPDATE\
                recording\
                SET\
                StatusID = ?,\
                ReceptionID = ?\
                WHERE\
                ID = ?";

                conn.query(sql, ["Окончен", id, recordID], function (err, result) {
                    if (err) return console.log(err);
                    delete req.session.recordID;
                    res.redirect("/");
                });
            });
    }
});

app.get("/doctorentry", function (req, res) {
    if (req.session.User == undefined) {
        res.redirect("/vhod");
    }
    else {
        let DateTime = [];
        
        const d = new Date();
        let dayWeek = d.getDay();
        let startData = new Date();
        if(dayWeek > 4){
            startData = startData.addDays(-(4 - dayWeek));
        }
        else{
            if(startData.getHours() >= 21){
                startData = startData.addDays(1);
                if(startData.getDay() > 4){
                    startData = startData.addDays(-(4 - dayWeek));
                }
                startData.setHours(9, 0, 0, 0);
            }
            else if(startData.getHours() < 9){
                startData.setHours(9, 0, 0, 0);
            }
            else{
                if(startData.getMinutes() < 30){
                    startData.setHours(startData.getHours(), 30, 0, 0);
                }
                else{
                    startData.setHours(startData.getHours() + 1, 0, 0, 0);
                    if(startData.getHours() >= 21){
                        startData = startData.addDays(1);
                        if(startData.getDay() > 4){
                            startData = startData.addDays(-(4 - dayWeek));
                        }
                        startData.setHours(9, 0, 0, 0);
                    }
                } 
            }
        }
        
        for (let index = 0; index < 5; index++) {
            if(index != 0){
                startData.setHours(9, 0, 0, 0);
            }
            let myToString = function (number) {
                return number.toLocaleString('en-US', {
                    minimumIntegerDigits: 2,
                    useGrouping: false
                });
            }
            
            let Date = myToString(startData.getDate()) + "." + myToString(startData.getMonth());
            let Times = [];
            while (startData.getHours() < 21) {
                Times.push({Time: myToString(startData.getHours()) + ":" + myToString(startData.getMinutes()), DateObject: (startData.toISOString().split('T')[0] + '+' + startData.toTimeString().split(' ')[0])});
                startData = startData.addMinutes(30);
            }
            startData = startData.addDays(1);
            dayWeek = startData.getDay();
            if(dayWeek > 4){
                startData = startData.addDays(-(4 - dayWeek));
            }
            DateTime.push({Date: Date, Times: Times});
        }

        conn.query("SELECT Name, Surname, Patronymic, PositionName, user.Login FROM user JOIN employee ON user.Login = employee.Login WHERE PositionName != ?",
            ["Медсестра"], function (err, employee_data) {
                if (err) return console.log(err);
                let all_emploee = new Map();
                employee_data.forEach(employee => {
                    if (!all_emploee.has(employee.PositionName)) {
                        all_emploee.set(employee.PositionName, []).get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                    else {
                        all_emploee.get(employee.PositionName).push({
                            Name: employee.Name,
                            Surname: employee.Surname,
                            Patronymic: employee.Patronymic,
                            PositionName: employee.PositionName,
                            Login: employee.Login
                        });
                    }
                });
                conn.query("SELECT Name, Surname, Patronymic, user.Login FROM user JOIN patient ON user.Login = patient.Login", function (err, patient_data) {
                    if (err) return console.log(err);
                    res.render(__dirname + "\\View\\medsister\\" + "medsis_entry.hbs", {
                        Name: req.session.User.Name,
                        Surname: req.session.User.Surname,
                        Patornymic: req.session.User.Patronymic,
                        Positions: all_emploee,
                        Patients: patient_data,
                        DateTime: DateTime
                    });
                });
            });
    }
});

app.post("/doctorentry", async function (req, res) {
    if (!req.body) return res.sendStatus(400);
    if (req.session.User == undefined) return res.send("Вы не авторизованы")
    else {
        let date = new Date();
        let DataTime = req.body.time.replace("+", " ");
        let EmployeeID = req.body.doctor;
        let PatientID = req.body.patient;
        let ReceptionID = null;
        let StatusID = "Назначен";

        conn.query("INSERT INTO recording (DateTime, EmployeeID, PatientID, ReceptionID, StatusID) VALUES (?,?,?,?,?)",
            [DataTime, EmployeeID, PatientID, ReceptionID, StatusID], function (err, data) {
                if (err) return console.log(err);
                res.redirect("/");
            })

    }
});


app.get("/", function (req, res) {
    if (req.session.User == undefined) return res.redirect("/vhod");
    if (req.session.User.UserType == "Пациент") return res.redirect("/patientmain");
    if (req.session.User.UserType == "Сотрудник") {
        GetEmployee(req.session.User.Login, function (result) {
            if (result[0].PositionName == "Медсестра") {
                res.redirect("/medsismain");
            }
            else {
                return res.redirect("/employeemain");
            }
        });
    }
});

app.listen(3000);