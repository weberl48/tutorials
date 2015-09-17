
<?php


/* ==================================================== 
 
GardenBot
	computer module, visualization sub-module, PHP data-conversion script
	beta version 0.1 (2010-08)

written by Andrew Frueh
http://gardenbot.org/

This is the code for the local-connection sub-module of the computer module of GardenBot.
This code should be run in the Processing environment (www.processing.org).
This code communicates with the brain module (Arduino) and can record the data to a text file and/or the web.
 
==================================================== */




// ================================================================
// >> process chart data

// >> load data
$dataStringIN = $_POST['sensorData'];
//$dataStringIN = file_get_contents($_GET['chartData']);

// break the input srting into an array
$dataRows = explode("\n", $dataStringIN);

if(count($dataRows)>0){
	// remove the header
	$dataLabels = explode(",", array_shift($dataRows));
	array_shift($dataRows);
	array_shift($dataRows);
	
	// >> clip down to the last x number of days
	// only show the last n days worth of readings
	$daysToDisplay = 3;
	$numOfReadingsPerHour = 4;
	$numOfSamplesToDisplay = ($daysToDisplay * $numOfReadingsPerHour * 24);
	// then multiply the number of days to get the number of readings
	if( count($dataRows) >= $numOfSamplesToDisplay ){
		$readingStartIndex = count($dataRows) - $numOfSamplesToDisplay;
		$dataRows = array_slice($dataRows, $readingStartIndex);
	}
	// << clip down to the last x number of days
	
	for($i=0; $i<count($dataRows)-1; $i++){
		// each line, consists of one of each data type
		$dataINArray[$i] = explode(",", $dataRows[$i]);
		$dataOUTArray['datetime'][$i] = $dataINArray[$i][0]; // string date
		$dataOUTArray['MS1'][$i] = intval($dataINArray[$i][1]); // int MS1
		$dataOUTArray['TP1'][$i] = intval($dataINArray[$i][2])*10;
		$dataOUTArray['LI1'][$i] = intval($dataINArray[$i][3]);
		$dataOUTArray['WIO'][$i] = intval($dataINArray[$i][4])*1000;
		$dataOUTArray['MS2'][$i] = intval($dataINArray[$i][5]);
	}
}
// << load data

// << process chart data
// ================================================================




// ================================================================
// >> OpenFlashChart

include 'open-flash-chart/php-ofc-library/open-flash-chart.php';
//echo $chart->toPrettyString();


// the title on the tooltip (and some other random properties) do not work! WHY?
$MS_tooltip = new tooltip( "Hello<br>val = #val#" );
$MS_tooltip->set_shadow( true );
$MS_tooltip->set_stroke( 3 );
$MS_tooltip->set_colour( "#6E604F" );
$MS_tooltip->set_background_colour( "#bb9966" );
$MS_tooltip->set_title_style( "{font-size: 14px; color: #CC2A43;}" );
/*
$MS_tooltip->set_body_style( "{font-size: 10px; font-weight: bold; color: #000000;}" );
*/

$dateTimeArrayLen = count($dataOUTArray['datetime']);
$MS_x = new x_axis();
// grid line and tick every 10
$MS_x->set_range(0,$dateTimeArrayLen);
$MS_x->set_steps(4);

/*
$MS_x->set_range(
    //$dataOUTArray['datetime']   // <-- max == 31st Jan, this year
    mktime(0, 0, 0, 6, 11, 2010),    // <-- min == 1st Jan, this year
    mktime(0, 0, 0, 6, 12, 2010)    // <-- max == 31st Jan, this year
    );
*/
// show ticks and grid lines every n
$MS_labels = new x_axis_labels();
// tell the labels to render the number as a date:
$MS_labels->set_labels( $dataOUTArray['datetime'] );
$MS_labels->text('#date:Y-m-d_h-i-s#');
// generate labels for every day
$MS_labels->set_steps(40);
// only display every n
//$MS_labels->visible_steps(10);
$MS_labels->rotate(45);
// finally attach the label definition to the x axis
$MS_x->set_labels($MS_labels);

// >> MS1
// setup the chart elements
$MS_title = new title( "GardenBot sensor readings \n updated - ".$dataOUTArray['datetime'][$dateTimeArrayLen-1]);
$MS_title->set_style( "{font-size: 20px; font-family: Georgia; font-weight: bold; color: #A2ACBA; text-align: center;}" );
$MS_y = new y_axis();
$MS_y->set_range( 0, 1023, 100);

// MS1
$MS1_data = new line();
$MS1_data->set_values( $dataOUTArray['MS1'] );
$MS1_data->colour( '#56a6f8' );
$MS1_data->set_key( $dataLabels[1], 12 );
//$MS1_data->set_fill_colour( '#56a6f8' );
//$MS1_data->set_fill_alpha( 0.3 );
// WHY doesn't this work???
//$MS1_data->set_tooltip( "MS1<br>{#val#}" );

// TP1
$TP1_data = new line();
$TP1_data->set_values( $dataOUTArray['TP1'] );
$TP1_data->colour( '#cccccc' );

// LI1
$LI1_data = new area();
$LI1_data->set_values( $dataOUTArray['LI1'] );
$LI1_data->colour( '#f2eb16' );
$LI1_data->set_fill_colour( '#f2eb16' );
$LI1_data->set_fill_alpha( 0.5 );

// WIO
$WIO_data = new area();
$WIO_data->set_values( $dataOUTArray['WIO'] );
$WIO_data->colour( '#0a78e9' );
$WIO_data->set_fill_colour( '#0a78e9' );
$WIO_data->set_fill_alpha( 0.5 );

// MS2
$MS2_data = new line();
$MS2_data->set_values( $dataOUTArray['MS2'] );
$MS2_data->colour( '#a1cefb' );
$MS2_data->set_key( $dataLabels[5], 12 );
//$MS2_data->set_fill_colour( '#a1cefb' );
//$MS2_data->set_fill_alpha( 0.3 );
//$MS2_data->set_tooltip( $MS_tooltip );
//$MS2_data->set_tooltip( "MS2<br>{#val#}" );


// create the chart
//   note: that the order you declare these elements defines the visual stacking order of the acual chart
$MS_chart = new open_flash_chart();
$MS_chart->set_title( $MS_title );
$MS_chart->add_element( $TP1_data );
$MS_chart->add_element( $WIO_data );
$MS_chart->add_element( $LI1_data );
$MS_chart->add_element( $MS1_data );
$MS_chart->add_element( $MS2_data );
$MS_chart->set_y_axis( $MS_y ); // Add the Y Axis object to the chart:
$MS_chart->set_x_axis( $MS_x ); // Add the Y Axis object to the chart:
$MS_chart->set_tooltip( $MS_tooltip );

//
$MS_fileString = $MS_chart->toString();
// << MS1

// << OpenFlashChart
// ================================================================



// ================================================================
// >> file output

// create the file
file_put_contents("chartData_MS.json",$MS_fileString);
//file_put_contents("chartData_MS2.json",$MS2_fileString);
file_put_contents("sensorData_backup.csv",$dataStringIN);

// << file output
// ================================================================


?>
