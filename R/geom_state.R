#' Title
#'
#' @param data
#' @param scales
#' @param county
#'
#' @return
#' @export
#'
#' @examples
#' library(dplyr)
#' #state_attributes |> rename(state = state_name) |> compute_panel_state() |> head()
compute_panel_state <- function(data, scales, keep_state = NULL, drop_state = NULL, alaska_shift, hawaii_shift, alaska_shrink){

  reference_filtered <- state_reference_full
  #
  if(!is.null(keep_state)){

    keep_state %>% tolower() -> keep_state

    reference_filtered %>%
      dplyr::filter(.data$state_name %>%
                      tolower() %in%
                      keep_state |
                      .data$state_abb %>%
                      tolower() %in%
                      keep_state
                      ) ->
      reference_filtered

  }

  if(!is.null(drop_state)){

    drop_state %>% tolower() -> drop_state

    reference_filtered %>%
      dplyr::filter(!(.data$state_name %>%
                      tolower() %in%
                      drop_state)) ->
      reference_filtered

  }

  # to prevent overjoining
  reference_filtered %>%
    dplyr::rename(state = state_name) %>%
    dplyr::select("state", "state_abb", "geometry",
                  "xmin","xmax", "ymin", "ymax"
                  ) ->
    reference_filtered


  data %>%
    dplyr::inner_join(reference_filtered
                      # , by = "state"
                      ) %>%
    dplyr::mutate(group = -1) %>%
    dplyr::select(-state)

}


StatUsstate <- ggplot2::ggproto(`_class` = "StatUsstate",
                                 `_inherit` = ggplot2::Stat,
                                 compute_panel = compute_panel_state,
                                 default_aes = ggplot2::aes(geometry =
                                                              ggplot2::after_stat(geometry)))



#' Title
#'
#' @param mapping
#' @param data
#' @param position
#' @param na.rm
#' @param show.legend
#' @param inherit.aes
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(state_attributes) +
#' aes(state = state_name) +
#' geom_state()
#'
#' ggplot(state_attributes) +
#' aes(state = state_name) +
#' geom_state(drop_state = c("Hawaii", "Alaska"))
#'
#' ggplot(state_attributes) +
#' aes(state = state_name) +
#' geom_state(drop_state = c("Hawaii", "Alaska")) +
#' aes(fill = Frost)
geom_state <- function(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE, ...
) {

  c(ggplot2::layer_sf(
    stat = StatUsstate,  # proto object from step 2
    geom = ggplot2::GeomSf,  # inherit other behavior
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = rlang::list2(na.rm = na.rm, ...)),
    coord_sf(default = TRUE)
  )

}






