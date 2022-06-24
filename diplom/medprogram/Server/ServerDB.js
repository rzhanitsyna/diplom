import { createConnection } from "mysql2";

const User = { Patient: 'patient', Specialist: 'specialist', All: 'all', Null:"null" };

var conn = createConnection({
  host: "localhost",
  user: "root",
  database: "diplom",
  password: "root"
});

export function CheckPessword(login, pessword, callback){
  var sql = "SELECT a from b where info = data";
  conn.query(sql, function(err, results){
    if (err) {throw err;}
    console.log(results[0].objid);
    stuff_i_want = results[0].objid;
    return callback(results[0].objid);
    })
}

export function GetUser(login, callback){ 
  var sql = "SELECT * FROM user WHERE Login = ?";
  conn.query(sql, [login], function(err, results){
    if (err) {throw err;}
    return callback(results);
  });
}

export function GetEmployee(login, callback){ 
  var sql = "SELECT * FROM Employee WHERE Login = ?";
  conn.query(sql, [login], function(err, results){
    if (err) {throw err;}
    return callback(results);
  });
}




export function SearchUser(login){
  conn.connect();
  
  var isPatient = conn.execute("SELECT * FROM patient WHERE Login =?", [login],
  function(err, results, fields) {
    return results.length == 0;
  });

  var isSpecialist = conn.execute("SELECT * FROM specialist WHERE Login =?", [login],
  function(err, results, fields) {
    return results.length == 0;
  });

  conn.end();

  if(isPatient){
    return User.Patient;
  }
  if(isSpecialist){
    return User.Specialist;
  }

  if(isSpecialist && isPatient){
    return User.All;
  }

  if(!isSpecialist && !isPatient){
    return User.Null;
  }  
}








