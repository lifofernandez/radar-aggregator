<?php

//======================================================================
// Sistema de templates para el Radar
//======================================================================



//-----------------------------------------------------
// Importar librerias
//-----------------------------------------------------

// composer require twig/twig:~1.0
// composer require twig/extensions
require_once '../vendor/autoload.php';

/*
* Esto va si se isntala de a mano
* require_once '../vendor/Twig-1.24.0/lib/Twig/Autoloader.php';
* Twig_Autoloader::register();
*/



//-----------------------------------------------------
// Parametros globales desde la URL
//-----------------------------------------------------

if(isset($_GET["categoria"])){
	$categoria = $_GET["categoria"];
}



//-----------------------------------------------------
// Twig
//-----------------------------------------------------

$loader = new Twig_Loader_Filesystem('../templates');
$twig = new Twig_Environment($loader);
$twig->addExtension(new Twig_Extensions_Extension_Intl());

// Custom Filter 'slug' 
$filter = new Twig_SimpleFilter('slug', function ($string) {
	$string = transliterator_transliterate("Any-Latin; NFD; [:Nonspacing Mark:] 
		Remove; NFC; [:Punctuation:] Remove; Lower();", $string);
    $string = preg_replace('/[-\s]+/', '-', $string);
    $string = trim($string, '-');
    return $string;
});
$twig->addFilter($filter);

// Templates 
$index = $twig->loadTemplate('index.html.twig');



//-----------------------------------------------------
// Cargar Feeds .json
//-----------------------------------------------------

$feedsJson = file_get_contents("../hoy.json");
$feeds = json_decode($feedsJson,true); // 'true' devuelve  array



//-----------------------------------------------------
// Filtros para las entradas
//-----------------------------------------------------

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



//-----------------------------------------------------
// Render
//-----------------------------------------------------

echo $sitemap->render($feeds);



//-----------------------------------------------------
// Reserva/Trash
//-----------------------------------------------------

// $html = $template->render($feeds);

// $config = array(
//            'indent'         => true,
//            'output-xhtml'   => true,
//            'wrap'           => 200);

// // Tidy
// $tidy = new tidy;
// $tidy->parseString($html, $config, 'utf8');
// $tidy->cleanRepair();

// Output
// echo $tidy;




?>