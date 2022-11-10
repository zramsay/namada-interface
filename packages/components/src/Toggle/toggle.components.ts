import styled from "styled-components";
import { DesignConfiguration } from "@anoma/utils";

const COMPONENT_WIDTH_PIXELS = 46;
const CIRCLE_DIAMETER_PIXELS = 20;
const BORDER_PIXELS = 2;

const transition = "all 0.3s ease-in-out";

enum ComponentColor {
  CircleBackground,
  ToggleBackground,
  ToggleBorder,
}

const getColor = (
  toggleColor: ComponentColor,
  theme: DesignConfiguration
): string => {
  const isDark = theme.themeConfigurations.isLightMode;
  switch (toggleColor) {
    case ComponentColor.CircleBackground:
      return isDark ? theme.colors.primary.main : theme.colors.secondary.main;
    case ComponentColor.ToggleBackground:
      return isDark
        ? theme.colors.utility1.main60
        : theme.colors.utility1.main20;
    case ComponentColor.ToggleBorder:
      return theme.colors.primary.main;
  }
};

export const ToggleContainer = styled.button<{
  checked: boolean;
  isLoading?: boolean;
}>`
  display: flex;
  align-items: center;
  width: ${COMPONENT_WIDTH_PIXELS}px;
  height: ${CIRCLE_DIAMETER_PIXELS + BORDER_PIXELS + BORDER_PIXELS}px;
  padding: 0;
  padding-left: ${(props) =>
    props.checked
      ? `${BORDER_PIXELS - 1}px`
      : `${
          COMPONENT_WIDTH_PIXELS - CIRCLE_DIAMETER_PIXELS - 1 - BORDER_PIXELS
        }px`};
  border: 1px solid
    ${(props) => getColor(ComponentColor.ToggleBackground, props.theme)};
  border-radius: 999px;
  background-color: ${(props) =>
    getColor(ComponentColor.ToggleBackground, props.theme)};
  /* TODO: Make this work for all toggles, not just theme selection */
  transition: ${transition};
  cursor: pointer;
`;

export const ToggleCircle = styled.div<{
  checked: boolean;
}>`
  display: flex;
  justify-content: center;
  align-items: center;
  width: ${CIRCLE_DIAMETER_PIXELS}px;
  max-width: ${CIRCLE_DIAMETER_PIXELS}px;
  height: ${CIRCLE_DIAMETER_PIXELS}px;
  border: none;
  border-radius: 50%;
  background-color: ${(props) =>
    getColor(ComponentColor.CircleBackground, props.theme)};
  box-sizing: border-box;
  transition: ${transition};
`;