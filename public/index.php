<?php

/*	Imports	*/

//////////////
//
//	Esto va si se isntala de github
//	require_once '../vendor/Twig-1.24.0/lib/Twig/Autoloader.php';
// 	Twig_Autoloader::register(); 

//////////////
//
//	esto va si: composer require twig/twig:~1.0
require_once '../vendor/autoload.php';


/*	Twig 	*/

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$twig->addExtension(new Twig_Extensions_Extension_Intl());

$categoria = $_GET["categoria"];






$template = $twig->loadTemplate('index.html.twig');


/*	Cargar	*/

$feedsJson = file_get_contents("../hoy.json");
$feeds = json_decode($feedsJson,true); // 'true' devuelve  array


/* Filtro 	*/

$twig->addGlobal('cat', $categoria);
// var_dump($feeds["timestamp"]);

// foreach ($feeds["timestamp"] as $feed){
// 	var_dump($feed[0]["feed_categories"]);
// }

/*	Render	*/

echo $template->render($feeds);

/*	Leesto!	*/


?>