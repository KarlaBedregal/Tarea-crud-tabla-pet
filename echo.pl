#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use DBI;

# Crear el objeto CGI
my $cgi = CGI->new;
print $cgi->header('text/html', charset => 'utf-8');

# Conexión a la base de datos
my $dsn = "DBI:mysql:;host=localhost";
my $user = "user"; 
my $password = "tu_contraseña_nueva";

# Conectar a MySQL sin especificar una base de datos
my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });

# Crear la nueva base de datos si no existe
$dbh->do("CREATE DATABASE IF NOT EXISTS nueva_base_datos");

# Usar la base de datos creada
$dbh->do("USE nueva_base_datos");

# Crear la tabla 'mascotas_info' si no existe
$dbh->do("CREATE TABLE IF NOT EXISTS mascota_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    sexo VARCHAR(10),
    fecha_nacimiento DATE,
    fecha_fallecimiento DATE
)");

# Mostrar formulario para agregar mascota
print $cgi->start_html('Registrar Mascota');
print "<h2>Formulario para registrar una mascota</h2>";

print <<HTML;
<form id="form-mascota">
    Nombre: <input type="text" id="nombre" name="nombre" required><br>
    Sexo: <input type="text" id="sexo" name="sexo" required><br>
    Fecha de Nacimiento: <input type="date" id="fecha_nacimiento" name="fecha_nacimiento" required><br>
    Fecha de Fallecimiento: <input type="date" id="fecha_fallecimiento" name="fecha_fallecimiento"><br>
    <input type="submit" value="Registrar">
</form>

<h3>Lista de Mascotas Registradas</h3>
<div id="resultado"></div>

<script>
document.getElementById('form-mascota').onsubmit = function(event) {
    event.preventDefault();  // Evitar que se envíe el formulario de forma convencional

    var formData = new FormData(document.getElementById('form-mascota'));
    
    // Realizar la solicitud AJAX al script Perl
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'myScriptAjax.pl', true);
    xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                var response = JSON.parse(xhr.responseText);
                if (response.success) {
                    document.getElementById('resultado').innerHTML = "Mascota registrada correctamente.";
                    loadMascotas();  // Actualizar la lista de mascotas
                } else {
                    document.getElementById('resultado').innerHTML = "Error al registrar la mascota.";
                }
            }
        };
        xhr.send(formData);
};

// Función para cargar y mostrar la lista de mascotas registradas
function loadMascotas() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'myScriptAjax.pl?action=listar', true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var mascotas = JSON.parse(xhr.responseText);
            var output = "<table border='1'><thead><tr><th>Nombre</th><th>Sexo</th><th>Fecha de Nacimiento</th></tr></thead><tbody>";
            mascotas.forEach(function(mascota) {
                output += "<tr><td>" + mascota.nombre + "</td><td>" + mascota.sexo + "</td><td>" + mascota.fecha_nacimiento + "</td></tr>";
            });
            output += "</tbody></table>";
            document.getElementById('resultado').innerHTML = output;
        }
    };
    xhr.send();
}

    // Cargar la lista de mascotas cuando se carga la página
    window.onload = function() {
        loadMascotas();
    };
    </script>
HTML

# Cerrar la conexión a la base de datos
$dbh->disconnect;

print $cgi->end_html;

