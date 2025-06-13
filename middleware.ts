import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

const isPublicRoute = createRouteMatcher(["/", "/sign-in(.*)", "/sign-up(.*)"]);

export default clerkMiddleware((auth, request) => {
  const { userId } = auth();
  const url = new URL(request.url);

  // Redirect authenticated users from public routes (except "/") to dashboard
  if (userId && isPublicRoute(request) && url.pathname !== "/") {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // Protect non-public routes
  if (!isPublicRoute(request)) {
    auth().protect(); // Ensure protection
  }

  return NextResponse.next(); // Always return a response
});

export const config = {
  matcher: [
    // Match all routes except static files and Next.js internals
    "/((?!_next|.*\\..*).*)",
    // Also match API routes
    "/(api|trpc)(.*)",
  ],
};
