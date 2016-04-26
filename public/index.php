<?php


/*	Tmpl 	*/

// require_once '../vendor/Twig-1.24.0/lib/Twig/Autoloader.php';
require_once '../vendor/autoload.php';
// Twig_Autoloader::register();

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$template = $twig->loadTemplate('index.html.twig');


/*	Cargar	*/

$feedsJson = file_get_contents("hoy.json");
//var_dump($feedsJson);
$feeds = json_decode($feedsJson,true); // 'true' devuelve  array


/*	Render	*/

echo $template->render($feeds);

/*	Leesto!	*/


?>