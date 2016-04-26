<?php


/*	Tmpl 	*/

// require_once '../vendor/Twig-1.24.0/lib/Twig/Autoloader.php';
require_once '../vendor/autoload.php';
// Twig_Autoloader::register();

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$template = $twig->loadTemplate('index.html.twig');


/*	Cargar	*/

$entriesJson = file_get_contents('hoy.json');
$entries = json_decode($entriesJson,true); // 'true' devuelve  array


/*	Render	*/

echo $template->render($entries);

/*	Leesto!	*/


?>