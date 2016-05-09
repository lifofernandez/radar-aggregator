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


/* Params 	*/

if(isset($_GET["categoria"])){
	$categoria = $_GET["categoria"];
}



/*	Twig 	*/

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$twig->addExtension(new Twig_Extensions_Extension_Intl());


$template = $twig->loadTemplate('index.html.twig');
// $style = $twig->loadTemplate('overrides.css.twig');


/*	Cargar	*/

$feedsJson = file_get_contents("../hoy.json");
$feeds = json_decode($feedsJson,true); // 'true' devuelve  array


/* Filtro 	*/

#?categoria[]=arte&categoria[]=web&categoria[]=videogames

if(isset($categoria)){
	if(!is_array($categoria)){
		$categoria = array($categoria);
	}

	if (array_intersect($categoria, $feeds["categories_main"])) {
		$twig->addGlobal('cats', $categoria);
	}

}else{
	$twig->addGlobal('cats', array("all"));
}


/*	Render	*/

echo $template->render($feeds);


/*	Leesto!	*/


?>