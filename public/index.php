<?php


/*	Tmpl 	*/

// require_once '../vendor/Twig-1.24.0/lib/Twig/Autoloader.php';
require_once '../vendor/autoload.php';
// Twig_Autoloader::register(); //esto va si se isntala de github

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$twig->addExtension(new Twig_Extensions_Extension_Intl());

$template = $twig->loadTemplate('index.html.twig');


/*	Cargar	*/

$feedsJson = file_get_contents("../hoy.json");
//var_dump($feedsJson);
$feeds = json_decode($feedsJson,true); // 'true' devuelve  array


/*	Render	*/

echo $template->render($feeds);

/*	Leesto!	*/


?>