import { ActionButton, Input } from "@namada/components";
import { AppContext } from "App/App";
import React, { useContext, useEffect, useState } from "react";
import { endpoint } from "utils";
import {
  ButtonContainer,
  InputContainer,
  SettingsContainer,
  SettingsFormContainer,
} from "./App.components";

export const SettingsForm: React.FC = () => {
  const [isFormValid, setIsFormValid] = useState(false);
  const { setIsModalOpen, baseUrl, setUrl } = useContext(AppContext)!;
  const [apiUrl, setApiUrl] = useState(baseUrl);
  const handleFocus = (e: React.ChangeEvent<HTMLInputElement>): void =>
    e.target.select();

  useEffect(() => {
    validateUrl(baseUrl);
  }, []);

  const validateUrl = (url: string): void => {
    try {
      new URL(url);
      setIsFormValid(true);
    } catch {
      setIsFormValid(false);
    }
  };

  const handleSetUrl = (url: string): void => {
    // Strip endpoint from URL if it was provided
    setUrl(url.replace(endpoint, ""));
    setIsModalOpen(false);
  };

  return (
    <SettingsContainer>
      <SettingsFormContainer>
        <InputContainer>
          <Input
            label="Set Faucet API URL"
            value={apiUrl}
            onFocus={handleFocus}
            onChange={(e) => {
              setApiUrl(e.target.value);
              validateUrl(e.target.value);
            }}
          />
        </InputContainer>
        <ButtonContainer>
          <ActionButton
            onClick={() => handleSetUrl(apiUrl)}
            disabled={!isFormValid || apiUrl === baseUrl}
          >
            Update URL
          </ActionButton>
        </ButtonContainer>
      </SettingsFormContainer>
    </SettingsContainer>
  );
};
