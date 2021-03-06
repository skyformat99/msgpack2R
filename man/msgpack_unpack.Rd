% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions.r
\name{msgpack_unpack}
\alias{msgpack_unpack}
\title{Msgpack Pack}
\usage{
msgpack_unpack(message)
}
\arguments{
\item{message}{A raw vector containing the message.}
}
\value{
The message pack object(s) converted into R types.  If more than one object exists in the message, a list of class "msgpack_set" containing the objects.
}
\description{
De-serialize a msgpack message.
}
\seealso{
See test.r for examples in the package directory.
}
