<?php

// Helper method to get a string description for an HTTP status code
// From http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
function getStatusCodeMessage($status)
{
    // these could be stored in a .ini file and loaded
    // via parse_ini_file()... however, this will suffice
    // for an example
    $codes = Array(
        100 => 'Continue',
        101 => 'Switching Protocols',
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        306 => '(Unused)',
        307 => 'Temporary Redirect',
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Requested Range Not Satisfiable',
        417 => 'Expectation Failed',
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported'
    );

    return (isset($codes[$status])) ? $codes[$status] : '';
}

// Helper method to send a HTTP response code/message
function sendResponse($status = 200, $body = '', $content_type = 'text/html')
{
    $status_header = 'HTTP/1.1 ' . $status . ' ' . getStatusCodeMessage($status);
    header($status_header);
    header('Content-type: ' . $content_type);
    echo $body;
}

function createVenueID($loc_lat, $loc_long) {
	if ( $loc_lat < 0 )
	{	
		$lat_prefix = 1;
		$loc_lat = abs($loc_lat);
	}
	else
	$lat_prefix = 0;
	if ( $loc_long < 0 )
	{
		$long_prefix = 1;
		$loc_long = abs($loc_long);	
	}	
	else
	$long_prefix = 0;
	
	$loc_lat = str_replace('.', '', $loc_lat);
	$loc_long = str_replace('.', '', $loc_long);
	return $lat_prefix . $loc_lat . $long_prefix . $loc_long;
	}

class RedeemAPI {

    private $db;

    // Constructor - open DB connection
    function __construct() {
        $this->db = new mysqli('mysql14.000webhost.com', 'a6349727_jayz', 'Bond2323', 'a6349727_frontru');
        $this->db->autocommit(FALSE);
    }

    // Destructor - close DB connection
    function __destruct() {
        $this->db->close();
    }

    // Main method to log new location
    function log_loc() {
    
        // Check for required parameters
        if (isset($_POST["loc_lat"]) && isset($_POST["loc_long"]) && isset($_POST["device_id"])) {
        
            // Put parameters into local variables
            $loc_lat = $_POST["loc_lat"];
            $loc_long = $_POST["loc_long"];
            $device_id = $_POST["device_id"];
	    
	    $venue_id = createVenueID($loc_lat, $loc_long);
            
            // Look up code in database
            $stmt = $this->db->prepare('SELECT name_venue FROM current_state_venue WHERE venue_id=?');
            $stmt->bind_param("s", $venue_id);
            $stmt->execute();
            $stmt->bind_result($name_venue);
            while ($stmt->fetch()) {
                break;
            }
            $stmt->close();
            
	// Bail if code doesn't exist
            if (empty($name_venue)) {
                $name_venue = "Unknown Place";
            }
            
            // Add tracking to checkin
            $stmt = $this->db->prepare("INSERT INTO check_out (name_venue, venue_id, device_id) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $name_venue, $venue_id, $device_id);
            $stmt->execute();
            $stmt->close();
            
            // Increment  people in venue
            $this->db->query("UPDATE current_state_venue SET devices_inside=devices_inside-1 WHERE venue_id=$venue_id");
	        $this->db->commit();
        
            sendResponse(200, 'Request fulfilled' );
            return true;
        }
        sendResponse(400, 'Invalid request');
        return false;
    
    }

}

$api = new RedeemAPI;
$api->log_loc();

?>
