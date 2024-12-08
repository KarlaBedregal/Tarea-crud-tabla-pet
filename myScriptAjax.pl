#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use DBI;
use JSON;

# Crear el objeto CGI
my $cgi = CGI->new;

# Verificar la acción que se está realizando
my $action = $cgi->param('action') || '';

# Conexión a la base de datos
my $dsn = "DBI:mysql:database=nueva_base_datos;host=localhost";
my $user = "user";
my $password = "tu_contraseña_nueva";

# Conectar a la base de datos
my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });

if ($action eq 'listar') {
    # Consultar las mascotas registradas
    my $sth = $dbh->prepare("SELECT * FROM mascota_info");
    $sth->execute();

    my $mascotas = [];
    while (my $row = $sth->fetchrow_hashref) {
        push @$mascotas, $row;
    }

    # Imprimir la cabecera para JSON
    print $cgi->header('application/json');
    # Devolver los datos en formato JSON
    print to_json($mascotas);
} else {
    # Recibir los datos del formulario para insertar una nueva mascota
    my $nombre = $cgi->param('nombre');
    my $sexo = $cgi->param('sexo');
    my $fecha_nacimiento = $cgi->param('fecha_nacimiento');
    my $fecha_fallecimiento = $cgi->param('fecha_fallecimiento');

    # Insertar los datos en la base de datos
    my $sth = $dbh->prepare("INSERT INTO mascota_info (nombre, sexo, fecha_nacimiento, fecha_fallecimiento) VALUES (?, ?, ?, ?)");
    $sth->execute($nombre, $sexo, $fecha_nacimiento, $fecha_fallecimiento);

    # Imprimir la cabecera para la respuesta AJAX en formato JSON
    print $cgi->header('application/json');
    # Responder con JSON confirmando el éxito
    print to_json({ success => 1, message => "Mascota registrada correctamente." });
}

# Cerrar la conexión a la base de datos
$dbh->disconnect;
