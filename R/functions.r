#' Simplify msgpack
#' @description A helper function for simplifying a msgpack return object
#' @param x Return object from msgpack_unpack.  
#' @return A simplified return object from msgpack_unpack.  E.g., arrays of all the same type are concatenated into an atomic vector.  
#' @export
msgpack_simplify <- function(x) {
    if(!is.list(x)) return(x)

    if(class(x)[1] == "map") {
        key = msgpack_simplify(x[["key"]])
        value = msgpack_simplify(x[["value"]])
        if(class(key) == "character") {
            names(value) <- key
            return(value)
        } else {
            x[["key"]] <- key
            x[["value"]] <- value
            return(x)
        }
    }

    len <- length(x)
    xc <- sapply(x, function(xi) class(xi)[1])
    xcu <- unique(xc)

    if(all(xcu %in% c("logical", "NULL"))) {
        x[which(xc == "NULL")] <- NA
        return(unlist(x))
    } else if(all(xcu %in% c("character", "NULL"))) {
        x[which(xc == "NULL")] <- NA_character_
        return(unlist(x))
    } else if(all(xcu %in% c("integer", "NULL"))) {
        x[which(xc == "NULL")] <- NA_integer_
        return(unlist(x))
    } else if(all(xcu %in% c("numeric", "integer", "NULL"))) {
        x[which(xc == "NULL")] <- NA_real_
        return(unlist(x))
    } else {
        for(i in which(xc %in% c("list", "map"))) {
            x[[i]] <- msgpack_simplify(x[[i]])
        }
        return(x)
    }
}

#' Format data for msgpack
#' @description A helper function to format R data for input to msgpack
#' @param x An r object.
#' @return A formatted R object to use as input to msgpack_pack.
#' @export
msgpack_format <- function(x) {
    xc <- class(x)[1]
    # print(xc)
    if(xc %in% c("logical", "integer", "numeric", "character")) {
        if(length(x) > 1) {
            xna <- which(is.na(x))
            x <- as.list(x)
            x[xna] <- list(NULL)
            return(x)
        } else {
            return(x)
        }
    } else if(xc == "raw") {
        return(x)
    } else if(xc == "list") {
        for(i in seq_along(x)) {
            x[[i]] <- msgpack_format(x[[i]])
        }
        return(x)
    } else if(xc == "map") {
        x <- msgpack_map(key=x[["key"]], value=x[["value"]])
        return(x)
    }
}

#' Msgpack Map
#' @description A helper function to create a map object for input to msgpack
#' @param key A list or vector of keys (coerced to list).  Duplicate keys are fine (connects to std::multimap in C++).  
#' @param value A list or vector of values (coerced to list).  This should be the same length as key.
#' @return An data.frame also of class "map" that can be used as input to msgpack_pack.  
#' @export
msgpack_map <- function(key, value) {
    for(a in attributes(key)) {
        attr(key, a) <- NULL
    }
    for(a in attributes(value)) {
        attr(value, a) <- NULL
    }    
    x <- list(key=as.list(key), value=as.list(value))
    attr(x, "row.names") <- seq_len(length(key))
    class(x) <- c("map", "data.frame")
    return(x)
}

#' Msgpack Pack
#' @description Serialize any number of objects into a single message.  
#' @param ... Any R objects that have corresponding msgpack types.  
#' @return A raw vector containing the message.  
#' @seealso See test.r for examples in the package directory.  
#' @export
msgpack_pack <- function(...) {
    obj_list <- list(...)
    if(length(obj_list) == 1) {
        return(c_pack(obj_list[[1]]))
    } else {
        class(obj_list) <- "msgpack_set"
        return(c_pack(obj_list))
    }
}

#' Msgpack Pack
#' @description De-serialize a msgpack message.  
#' @param message A raw vector containing the message.  
#' @return The message pack object(s) converted into R types.  If more than one object exists in the message, a list of class "msgpack_set" containing the objects.  
#' @seealso See test.r for examples in the package directory.  
#' @export
msgpack_unpack <- function(message) {
    c_unpack(message)
}