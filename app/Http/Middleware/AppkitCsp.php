<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AppkitCsp
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

       $allowedOrigins = config('app.env') === 'local'
    ? "http://localhost:*"
    : "https://basewavebeta.sarkaritool.com";

$response->header(
    'Content-Security-Policy-Report-Only',
    "frame-ancestors 'self' {$allowedOrigins} https://*.pages.dev https://*.vercel.app https://*.ngrok-free.app https://secure-mobile.walletconnect.com https://secure-mobile.walletconnect.org https://secure.walletconnect.org"
);

        $response->header('Cross-Origin-Opener-Policy', 'unsafe-none');
        return $response;
    }
}
