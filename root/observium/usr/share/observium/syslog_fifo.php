#!/usr/bin/env php
<?php

/**
 * Observium
 *
 *   This file is part of Observium.
 *
 * @package    observium
 * @subpackage syslog
 * @author     Adam Armstrong <adama@memetic.org>
 * @copyright  (C) 2006 - 2012 Adam Armstrong
 *
 */

$observium_dir="/usr/share/observium";

include("$observium_dir/includes/defaults.inc.php");
include("$observium_dir/config.php");
include("$observium_dir/includes/definitions.inc.php");
include("$observium_dir/includes/syslog.php");
include("$observium_dir/includes/dbFacile.php");
include("$observium_dir/includes/common.php");
include("$observium_dir/includes/functions.php");

$i = "1";

$s = fopen('/var/log/rsyslog-fifo','r');
while ($line = fgets($s))
{
  //echo $line;
  //logfile($line);
  // host || facility || priority || level || tag || timestamp || msg || program
  list($entry['host'],$entry['facility'],$entry['priority'], $entry['level'], $entry['tag'], $entry['timestamp'], $entry['msg'], $entry['program']) = explode("||", trim($line));
  process_syslog($entry, 1);
  unset($entry); unset($line);
  $i++;
}

?>
