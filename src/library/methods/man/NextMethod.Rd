\name{callNextMethod}
\alias{callNextMethod}
\title{Call an Inherited Method}
\description{
  A call to \code{callNextMethod} can only appear inside a method
  definition.  It then results in a call to the first inherited method
  after the current method, with the arguments to the current method
  passed down to the next method.  The value of that method call is the
  value of \code{callNextMethod}.
}
\usage{
callNextMethod(...)
}
\arguments{
  \item{\dots}{
Optionally, the arguments to the function in its next call
(but note that the dispatch is as in the detailed description below;
the arguments have no effect on selecting the next method.) 

If no arguments are included in the call to \code{callNextMethod}, the
    effect is to call the method with the current arguments.
    See the detailed description for what this really means.

Calling with no arguments is often the natural way to use
    \code{callNextMethod}; see the examples.
    }
}
\details{
  The ``next'' method (i.e., the first inherited method) is defined to
    be that method
  which \emph{would} have been called if the current method did not
  exist.
  This is more-or-less literally what happens: The current method is
  deleted from a copy of the methods for the current generic, and
  \code{\link{selectMethod}} is called to find the next method (the
  result is cached in a special object, so the search only typically
  happens once per session per combination of argument classes).

  It is also legal, and often useful, for the method called by
  \code{callNextMethod} to itself have a call to
  \code{callNextMethod}. This generally works as you would expect, but
  for completeness be aware that it is possible to have ambiguous
  inheritance in the S structure, in the sense that the same two
  classes can appear as superclasses \emph{in the opposite order} in
  two other class definitions.  In this case the effect of a nested
  instance of \code{callNextMethod} is not well defined.  Such
  inconsistent class hierarchies are both rare and nearly always the
  result of bad design, but they are possible, and currently undetected.

  The statement that the method is called with the current arguments is
  more precisely as follows.  Arguments that were missing in the current
  call are still missing (remember that \code{"missing"} is a valid
  class in a method signature).  For a formal argument, say \code{x}, that
  appears in the original call, there is a corresponding argument in the
  next method call equivalent to ``\code{x = x}''.  In effect, this
  means that the next method sees the same actual arguments, but
  arguments are evaluated only once.
}
\value{
  The value returned by the selected method.
}
\references{
  The R package \code{methods} implements, with a few exceptions, the
  programming interface for classes
  and methods in the book \emph{Programming with Data} (John
  M. Chambers, Springer, 1998), in particular sections 1.6, 2.7, 2.8,
  and chapters 7 and 8.

  While the programming interface for the methods package follows the reference,
  the R software is an original implementation, so details in
  the reference that reflect the S4 implementation may appear
  differently in R.  Also, there are extensions to the programming
  interface developed more recently than the reference.  For a
  discussion of details and ongoing development, see the web page 
  \url{http://developer.r-project.org/methodsPackage.html} and the
  pointers from that page.
}
\seealso{\link{Methods} for the general behavior of method dispatch}

\examples{

## some class definitions with simple inheritance
setClass("B0" , representation(b0 = "numeric"))

setClass("B1", "B0")

setClass("B2", representation("B1", b2 = "logical"))

## and a rather silly function to illustrate callNextMethod

f <- function(x) class(x)

setMethod("f", "B0", function(x) c(x@b0, callNextMethod()))

setMethod("f", "B2", function(x) c(x@b2, callNextMethod()))

b2 <- new("B2", b2 = FALSE, b0 = 10)

b1 <- new("B1", b0 = 2)

f(b2)

f(b1)

\testonly{

stopifnot(identical(f(b2), c(b2@b2, b2@b0, "B2")))



## next methods calling next methods; using group generics
setMethod("Ops", "B2",
    function(e1, e2) callNextMethod())
setMethod("Ops", c("B0","numeric"),
    function(e1, e2) callNextMethod(e1@b0, e2))

b2 + 1 # 11

b1 == 2 # TRUE

removeClass("B2"); removeClass("B1"); removeClass("B0")

removeGeneric("f")

removeMethods("Ops")

}

}
\keyword{programming}
\keyword{classes}
\keyword{methods}